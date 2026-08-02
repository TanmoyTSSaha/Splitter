import { BlockedActionBanner } from '../../components/app/BlockedActionBanner'
import { BalanceCards } from '../../components/app/BalanceCards'
import { ErrorCard } from '../../components/app/ErrorCard'
import { TransactionList } from '../../components/app/TransactionList'
import { useOverviewData } from '../../hooks/useOverviewData'
import { usePageMeta } from '../../hooks/usePageMeta'

export function OverviewPage() {
  usePageMeta('Overview', 'Your Splitr balances on the web.', '/app', { noIndex: true })
  const { balances, transactions, loading, error, reload } = useOverviewData()

  return (
    <div>
      <BlockedActionBanner />

      {error ? (
        <ErrorCard message={error} onRetry={() => void reload()} />
      ) : null}

      <BalanceCards
        youOwe={balances.youOwe}
        youAreOwed={balances.youAreOwed}
        loading={loading}
      />

      <TransactionList transactions={transactions} loading={loading} />
    </div>
  )
}
