import { BlockedActionBanner } from '../../components/app/BlockedActionBanner'
import { ErrorCard } from '../../components/app/ErrorCard'
import { GroupList } from '../../components/app/GroupList'
import { useGroupsList } from '../../hooks/useGroupsList'
import { usePageMeta } from '../../hooks/usePageMeta'

export function GroupsPage() {
  usePageMeta('Groups', 'Your Splitr groups on the web.', '/app/groups', { noIndex: true })
  const { groups, loading, error, reload } = useGroupsList()

  return (
    <div>
      <BlockedActionBanner />

      {error ? (
        <ErrorCard message={error} onRetry={() => void reload()} />
      ) : null}

      <GroupList groups={groups} loading={loading} />
    </div>
  )
}
