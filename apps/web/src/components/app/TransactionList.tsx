import { PLAY_STORE_CTA_LABEL, PLAY_STORE_URL } from '../../constants/site'
import { trackInstallClick } from '../../lib/analytics'
import { formatInr, formatTxnDate } from '../../lib/money'
import type { OverviewTransaction } from '../../lib/overview'
import { Button } from '../Button'
import styles from './TransactionList.module.css'

type Props = {
  transactions: OverviewTransaction[]
  loading?: boolean
}

export function TransactionList({ transactions, loading }: Props) {
  if (loading) {
    return (
      <section aria-busy="true" aria-label="Loading transactions">
        <h2 className={styles.heading}>Recent activity</h2>
        <div className={styles.list}>
          <div className={styles.skeletonRow} />
          <div className={styles.skeletonRow} />
          <div className={styles.skeletonRow} />
        </div>
      </section>
    )
  }

  if (transactions.length === 0) {
    return (
      <section className={styles.empty}>
        <h2 className={styles.emptyTitle}>No activity yet</h2>
        <p className={styles.emptyBody}>
          Add expenses in the Splitr app to see balances and transactions here.
        </p>
        <Button
          as="a"
          href={PLAY_STORE_URL}
          target="_blank"
          rel="noopener noreferrer"
          onClick={() => trackInstallClick('overview_empty')}
        >
          {PLAY_STORE_CTA_LABEL}
        </Button>
      </section>
    )
  }

  return (
    <section>
      <h2 className={styles.heading}>Recent activity</h2>
      <ul className={styles.list}>
        {transactions.map((txn) => (
          <li key={txn.id} className={styles.row}>
            <div className={styles.meta}>
              <p className={styles.title}>{txn.title}</p>
              <p className={styles.subtitle}>
                {txn.context ? `${txn.context} · ` : ''}
                {txn.subtitle} · {formatTxnDate(txn.date)}
              </p>
            </div>
            <span className={`${styles.amount} ${txn.isCredit ? styles.credit : styles.debit}`}>
              {txn.isCredit ? '+' : '−'}
              {formatInr(txn.amount)}
            </span>
          </li>
        ))}
      </ul>
    </section>
  )
}
