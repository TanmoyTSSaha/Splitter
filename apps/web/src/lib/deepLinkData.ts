import { supabase } from './supabase'

export type GroupInvitePreview = {
  kind: 'group'
  groupName: string
  groupId: string
  token: string
  isMember: boolean
}

export type FriendInvitePreview = {
  kind: 'friend'
  inviterName: string
  inviterId: string
}

export type DeepLinkPreview =
  | { status: 'loading' }
  | { status: 'invalid'; message: string }
  | { status: 'ready'; data: GroupInvitePreview | FriendInvitePreview }
  | { status: 'anonymous'; kind: 'group' | 'friend'; tokenOrId: string }

type PreviewInviteResponse = {
  kind: 'group' | 'friend'
  name: string
  valid: boolean
}

async function fetchPreviewInvite(
  body: { token: string } | { friendUserId: string },
): Promise<PreviewInviteResponse | null> {
  if (!supabase) return null

  const { data, error } = await supabase.functions.invoke('preview-invite', { body })
  if (error) return null
  if (!data || typeof data !== 'object') return null

  const row = data as Partial<PreviewInviteResponse>
  if (row.kind !== 'group' && row.kind !== 'friend') return null
  if (typeof row.valid !== 'boolean') return null

  return {
    kind: row.kind,
    name: String(row.name ?? '').trim(),
    valid: row.valid,
  }
}

function displayName(row: {
  user_name?: string | null
  firstname?: string | null
  lastname?: string | null
}): string {
  return (
    String(row.user_name ?? '').trim() ||
    `${String(row.firstname ?? '').trim()} ${String(row.lastname ?? '').trim()}`.trim() ||
    'Splitr user'
  )
}

export async function fetchGroupInvitePreview(
  token: string,
  userId?: string | null,
): Promise<DeepLinkPreview> {
  if (!supabase) {
    return { status: 'anonymous', kind: 'group', tokenOrId: token }
  }

  if (!userId) {
    const preview = await fetchPreviewInvite({ token })
    if (!preview) {
      return { status: 'anonymous', kind: 'group', tokenOrId: token }
    }
    if (!preview.valid || preview.kind !== 'group' || !preview.name) {
      return { status: 'invalid', message: 'This group invite is invalid or has expired.' }
    }
    return {
      status: 'ready',
      data: {
        kind: 'group',
        groupName: preview.name,
        groupId: '',
        token,
        isMember: false,
      },
    }
  }

  const { data, error } = await supabase
    .from('shareable_invites')
    .select('token, status, group_id, expires_at, groups(group_name)')
    .eq('token', token)
    .eq('status', 'active')
    .maybeSingle()

  if (error) throw error
  if (!data?.group_id) {
    return { status: 'invalid', message: 'This group invite is invalid or has expired.' }
  }

  const expiresAt = data.expires_at ? new Date(String(data.expires_at)) : null
  if (expiresAt && !Number.isNaN(expiresAt.getTime()) && expiresAt < new Date()) {
    return { status: 'invalid', message: 'This group invite has expired.' }
  }

  const groups = data.groups as { group_name?: string } | { group_name?: string }[] | null
  const groupName = Array.isArray(groups)
    ? String(groups[0]?.group_name ?? 'Group')
    : String(groups?.group_name ?? 'Group')

  const { data: membership } = await supabase
    .from('group_members')
    .select('group_id')
    .eq('group_id', data.group_id as string)
    .eq('user_id', userId)
    .maybeSingle()

  return {
    status: 'ready',
    data: {
      kind: 'group',
      groupName,
      groupId: data.group_id as string,
      token,
      isMember: Boolean(membership),
    },
  }
}

export async function fetchFriendInvitePreview(
  inviterId: string,
  currentUserId?: string | null,
): Promise<DeepLinkPreview> {
  if (!supabase) {
    return { status: 'anonymous', kind: 'friend', tokenOrId: inviterId }
  }

  if (!currentUserId) {
    const preview = await fetchPreviewInvite({ friendUserId: inviterId })
    if (!preview) {
      return { status: 'anonymous', kind: 'friend', tokenOrId: inviterId }
    }
    if (!preview.valid || preview.kind !== 'friend' || !preview.name) {
      return { status: 'invalid', message: 'This friend invite link is invalid.' }
    }
    return {
      status: 'ready',
      data: {
        kind: 'friend',
        inviterName: preview.name,
        inviterId,
      },
    }
  }

  if (inviterId === currentUserId) {
    return { status: 'invalid', message: 'You cannot accept your own friend invite.' }
  }

  const { data, error } = await supabase
    .from('users')
    .select('user_id, user_name, firstname, lastname')
    .eq('user_id', inviterId)
    .maybeSingle()

  if (error) throw error
  if (!data) {
    return { status: 'invalid', message: 'This friend invite link is invalid.' }
  }

  return {
    status: 'ready',
    data: {
      kind: 'friend',
      inviterName: displayName(data),
      inviterId,
    },
  }
}

export function groupJoinDeepLink(token: string): string {
  return `splitr://join/${token}`
}

export function friendInviteDeepLink(userId: string): string {
  return `splitr://invite/friend/${userId}`
}
