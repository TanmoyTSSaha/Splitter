import { BlockedActionBanner } from '../../components/app/BlockedActionBanner'
import { ErrorCard } from '../../components/app/ErrorCard'
import { FriendList } from '../../components/app/FriendList'
import { useFriendsList } from '../../hooks/useFriendsList'
import { usePageMeta } from '../../hooks/usePageMeta'

export function FriendsPage() {
  usePageMeta('Friends', 'Your Splitr friends on the web.', '/app/friends', { noIndex: true })
  const { friends, loading, error, reload } = useFriendsList()

  return (
    <div>
      <BlockedActionBanner />

      {error ? (
        <ErrorCard message={error} onRetry={() => void reload()} />
      ) : null}

      <FriendList friends={friends} loading={loading} />
    </div>
  )
}
