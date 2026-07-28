import { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import { DeepLinkPreviewCard } from '../components/deeplink/DeepLinkPreviewCard'
import { useAuth } from '../context/AuthContext'
import { usePageMeta } from '../hooks/usePageMeta'
import {
  fetchGroupInvitePreview,
  groupJoinDeepLink,
  type DeepLinkPreview,
} from '../lib/deepLinkData'

export function JoinGroupPage() {
  const { token } = useParams<{ token: string }>()
  const { user } = useAuth()
  const [preview, setPreview] = useState<DeepLinkPreview>({ status: 'loading' })
  const [fetchError, setFetchError] = useState<string | null>(null)

  useEffect(() => {
    if (!token) {
      setPreview({ status: 'invalid', message: 'Missing invite token.' })
      return
    }

    let mounted = true
    setPreview({ status: 'loading' })
    setFetchError(null)

    void fetchGroupInvitePreview(token, user?.id)
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
  }, [token, user?.id])

  const loading = preview.status === 'loading'
  const invalid = preview.status === 'invalid'
  const anonymous = preview.status === 'anonymous'
  const ready = preview.status === 'ready' && preview.data.kind === 'group' ? preview.data : null

  const title = ready?.groupName ?? (anonymous ? 'Group invite' : 'Invite unavailable')
  const subtitle = ready
    ? ready.isMember
      ? 'You are already in this group. Open the app to view expenses.'
      : 'Join this group in the Splitr app to split expenses together.'
    : 'This invite may be expired or already used.'

  const metaTitle = ready?.groupName ? `Join ${ready.groupName}` : 'Group invite'
  const metaDescription = ready?.groupName
    ? `Join ${ready.groupName} on Splitr to split expenses together.`
    : 'Join a group on Splitr.'

  usePageMeta(metaTitle, metaDescription, token ? `/join/${token}` : '/join')

  return (
    <DeepLinkPreviewCard
      eyebrow="Group invite"
      title={title}
      subtitle={subtitle}
      error={fetchError ?? (invalid ? preview.message : undefined)}
      loading={loading}
      isAuthenticated={Boolean(user)}
      appDeepLink={token ? groupJoinDeepLink(token) : 'splitr://'}
      webHref={ready?.isMember ? `/app/groups/${ready.groupId}` : undefined}
      installLocation="join_preview"
    />
  )
}
