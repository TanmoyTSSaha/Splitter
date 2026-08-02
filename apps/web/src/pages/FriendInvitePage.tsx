import { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import { DeepLinkPreviewCard } from '../components/deeplink/DeepLinkPreviewCard'
import { useAuth } from '../context/AuthContext'
import { usePageMeta } from '../hooks/usePageMeta'
import {
  fetchFriendInvitePreview,
  friendInviteDeepLink,
  type DeepLinkPreview,
} from '../lib/deepLinkData'

export function FriendInvitePage() {
  const { userId: inviterId } = useParams<{ userId: string }>()
  const { user } = useAuth()
  const [preview, setPreview] = useState<DeepLinkPreview>({ status: 'loading' })
  const [fetchError, setFetchError] = useState<string | null>(null)

  useEffect(() => {
    if (!inviterId) {
      setPreview({ status: 'invalid', message: 'Missing inviter.' })
      return
    }

    let mounted = true
    setPreview({ status: 'loading' })
    setFetchError(null)

    void fetchFriendInvitePreview(inviterId, user?.id)
      .then((result) => {
        if (mounted) setPreview(result)
      })
      .catch((err) => {
        if (!mounted) return
        setFetchError(err instanceof Error ? err.message : 'Could not load invite.')
        setPreview({ status: 'invalid', message: 'Could not load this invite.' })
      })

    return () => {
      mounted = false
    }
  }, [inviterId, user?.id])

  const loading = preview.status === 'loading'
  const invalid = preview.status === 'invalid'
  const anonymous = preview.status === 'anonymous'
  const ready =
    preview.status === 'ready' && preview.data.kind === 'friend' ? preview.data : null

  const title = ready?.inviterName ?? (anonymous ? 'Friend invite' : 'Invite unavailable')
  const subtitle = ready
    ? `${ready.inviterName} invited you to connect on Splitr. Accept in the app.`
    : 'This friend invite link is not valid.'

  const metaTitle = ready?.inviterName
    ? `Friend invite from ${ready.inviterName}`
    : 'Friend invite'
  const metaDescription = ready?.inviterName
    ? `${ready.inviterName} invited you to connect on Splitr.`
    : 'Connect with a friend on Splitr.'

  usePageMeta(metaTitle, metaDescription, inviterId ? `/invite/friend/${inviterId}` : '/invite/friend')

  return (
    <DeepLinkPreviewCard
      eyebrow="Friend invite"
      title={title}
      subtitle={subtitle}
      error={fetchError ?? (invalid ? preview.message : undefined)}
      loading={loading}
      isAuthenticated={Boolean(user)}
      appDeepLink={inviterId ? friendInviteDeepLink(inviterId) : 'splitr://'}
      webHref={ready ? `/app/friends/${ready.inviterId}` : undefined}
      installLocation="friend_preview"
    />
  )
}
