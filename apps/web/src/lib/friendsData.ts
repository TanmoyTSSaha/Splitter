import { supabase } from './supabase'
import { formatInr, parseAmount, parseRate, toInr } from './money'
import { parseBalances } from './groupsData'

export type FriendSummary = {
  id: string
  name: string
  email?: string
  netBalance: number
}

export type FriendGroupBreakdown = {
  groupId: string
  groupName: string
  amount: number
}

export type FriendSharedTransaction = {
  id: string
  title: string
  groupName: string
  amount: number
  date: string
  direction: 'they_owe' | 'you_owe' | 'neutral'
}

export type FriendDetail = {
  id: string
  name: string
  email?: string
  totalOwed: number
  totalOwing: number
  netBalance: number
  groupBreakdown: FriendGroupBreakdown[]
  transactions: FriendSharedTransaction[]
}
async function fetchAcceptedFriends(userId: string): Promise<
  Array<{ friendUserId: string; name: string; email?: string }>
> {
  if (!supabase) return []

  const [sentRes, receivedRes] = await Promise.all([
    supabase.from('friends').select('id, user_id, friend_id, status').eq('user_id', userId),
    supabase.from('friends').select('id, user_id, friend_id, status').eq('friend_id', userId),
  ])

  if (sentRes.error) throw sentRes.error
  if (receivedRes.error) throw receivedRes.error

  const otherIds = new Set<string>()
  for (const row of [...(sentRes.data ?? []), ...(receivedRes.data ?? [])]) {
    if (row.status !== 'accepted') continue
    const otherId = row.user_id === userId ? (row.friend_id as string) : (row.user_id as string)
    otherIds.add(otherId)
  }

  if (otherIds.size === 0) return []

  const { data: users, error: usersError } = await supabase
    .from('users')
    .select('user_id, user_name, user_email, firstname, lastname')
    .in('user_id', [...otherIds])

  if (usersError) throw usersError

  const profileById = new Map<string, { name: string; email?: string }>()
  for (const user of users ?? []) {
    const name =
      String(user.user_name ?? '').trim() ||
      `${String(user.firstname ?? '').trim()} ${String(user.lastname ?? '').trim()}`.trim() ||
      'Friend'
    profileById.set(user.user_id as string, {
      name,
      email: user.user_email ? String(user.user_email) : undefined,
    })
  }

  return [...otherIds].map((friendUserId) => ({
    friendUserId,
    name: profileById.get(friendUserId)?.name ?? 'Friend',
    email: profileById.get(friendUserId)?.email,
  }))
}

async function fetchUserGroupsWithBalances(userId: string) {
  if (!supabase) return []

  const { data: memberships, error } = await supabase
    .from('group_members')
    .select('group_id')
    .eq('user_id', userId)

  if (error) throw error

  const groupIds = (memberships ?? []).map((row) => row.group_id as string)
  if (groupIds.length === 0) return []

  const { data: groups, error: groupError } = await supabase
    .from('groups')
    .select('group_id, group_name, group_balance')
    .in('group_id', groupIds)

  if (groupError) throw groupError
  return groups ?? []
}

function computeFriendBalance(
  userId: string,
  friendUserId: string,
  groups: Array<{ group_id: string; group_name: string | null; group_balance: unknown }>,
): Pick<FriendDetail, 'totalOwed' | 'totalOwing' | 'netBalance' | 'groupBreakdown'> {
  let totalOwed = 0
  let totalOwing = 0
  const groupBreakdown: FriendGroupBreakdown[] = []

  for (const group of groups) {
    for (const balance of parseBalances(group.group_balance)) {
      const amount = parseAmount(balance.amount)
      if (balance.donor_id === friendUserId && balance.receiver_id === userId) {
        totalOwed += amount
        groupBreakdown.push({
          groupId: group.group_id as string,
          groupName: String(group.group_name ?? 'Group'),
          amount,
        })
      }
      if (balance.donor_id === userId && balance.receiver_id === friendUserId) {
        totalOwing += amount
        groupBreakdown.push({
          groupId: group.group_id as string,
          groupName: String(group.group_name ?? 'Group'),
          amount: -amount,
        })
      }
    }
  }

  return {
    totalOwed,
    totalOwing,
    netBalance: totalOwed - totalOwing,
    groupBreakdown,
  }
}

export function formatSignedBalance(net: number): string {
  const prefix = net > 0 ? '+' : net < 0 ? '−' : ''
  return `${prefix}${formatInr(Math.abs(net))}`
}

export async function fetchFriends(userId: string): Promise<FriendSummary[]> {
  const friends = await fetchAcceptedFriends(userId)
  if (friends.length === 0) return []

  const groups = await fetchUserGroupsWithBalances(userId)

  return friends
    .map((friend) => {
      const { netBalance } = computeFriendBalance(userId, friend.friendUserId, groups)
      return {
        id: friend.friendUserId,
        name: friend.name,
        email: friend.email,
        netBalance,
      }
    })
    .sort((a, b) => a.name.localeCompare(b.name))
}

export async function fetchFriendDetail(
  userId: string,
  friendId: string,
): Promise<FriendDetail | null> {
  const friends = await fetchAcceptedFriends(userId)
  const friend = friends.find((f) => f.friendUserId === friendId)
  if (!friend) return null

  const groups = await fetchUserGroupsWithBalances(userId)
  const balance = computeFriendBalance(userId, friendId, groups)

  const sharedGroupIds = balance.groupBreakdown.map((g) => g.groupId)
  const transactions: FriendSharedTransaction[] = []

  if (supabase && sharedGroupIds.length > 0) {
    const groupNameById = new Map(
      groups.map((g) => [g.group_id as string, String(g.group_name ?? 'Group')]),
    )

    const { data: txns, error } = await supabase
      .from('group_transaction')
      .select(
        'transaction_group_id, group_id, shared_transaction_amount, currency, exchange_rate_to_inr, paid_by, shared_with, transaction_date, description',
      )
      .in('group_id', sharedGroupIds)
      .or(
        `and(paid_by.eq.${userId},shared_with.eq.${friendId}),and(paid_by.eq.${friendId},shared_with.eq.${userId})`,
      )
      .order('transaction_date', { ascending: false })
      .limit(40)

    if (error) throw error

    const grouped = new Map<string, FriendSharedTransaction>()

    for (const txn of txns ?? []) {
      const key = String(txn.transaction_group_id ?? txn.description)
      const amountInr = toInr(
        parseAmount(txn.shared_transaction_amount),
        txn.currency as string | null,
        parseRate(txn.exchange_rate_to_inr),
      )
      const paidBy = String(txn.paid_by)
      const direction =
        paidBy === friendId ? 'they_owe' : paidBy === userId ? 'you_owe' : 'neutral'

      const existing = grouped.get(key)
      if (!existing) {
        grouped.set(key, {
          id: key,
          title: String(txn.description ?? 'Expense'),
          groupName: groupNameById.get(String(txn.group_id)) ?? 'Group',
          amount: amountInr,
          date: String(txn.transaction_date),
          direction,
        })
      } else {
        existing.amount += amountInr
      }
    }

    transactions.push(
      ...[...grouped.values()].sort(
        (a, b) => new Date(b.date).getTime() - new Date(a.date).getTime(),
      ),
    )
  }

  return {
    id: friend.friendUserId,
    name: friend.name,
    email: friend.email,
    ...balance,
    transactions: transactions.slice(0, 15),
  }
}
