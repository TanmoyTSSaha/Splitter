import { formatInr } from '../../lib/money'
import styles from './BalanceCards.module.css'

type Props = {
  youOwe: number
  youAreOwed: number
  loading?: boolean
}

export function BalanceCards({ youOwe, youAreOwed, loading }: Props) {
  if (loading) {
    return (
      <div className={styles.grid} aria-busy="true" aria-label="Loading balances">
        <div className={styles.skeleton} />
        <div className={styles.skeleton} />
      </div>
    )
  }

  return (
    <div className={styles.grid}>
      <article className={styles.card}>
        <p className={styles.label}>You owe</p>
        <p className={`${styles.amount} ${styles.owe}`}>−{formatInr(youOwe)}</p>
      </article>
      <article className={styles.card}>
        <p className={styles.label}>You are owed</p>
        <p className={`${styles.amount} ${styles.owed}`}>+{formatInr(youAreOwed)}</p>
      </article>
    </div>
  )
}
