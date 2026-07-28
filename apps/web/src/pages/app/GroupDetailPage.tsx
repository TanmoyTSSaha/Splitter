import { Link, useParams } from 'react-router-dom'
import { BlockedActionBanner } from '../../components/app/BlockedActionBanner'
import { ErrorCard } from '../../components/app/ErrorCard'
import { useGroupDetail } from '../../hooks/useGroupDetail'
import { usePageMeta } from '../../hooks/usePageMeta'
import { formatInr, formatTxnDate, initials } from '../../lib/money'
import { formatSignedBalance } from '../../lib/groupsData'
import listStyles from '../../components/app/Groups.module.css'
import styles from './DetailPage.module.css'

export function GroupDetailPage() {
  const { groupId } = useParams<{ groupId: string }>()
  const { detail, loading, error, reload } = useGroupDetail(groupId)

  usePageMeta(
    detail?.name ?? 'Group',
    'Group details on Splitr web.',
    groupId ? `/app/groups/${groupId}` : '/app/groups',
    { noIndex: true },
  )

  if (loading) {
    return (
      <div aria-busy="true" aria-label="Loading group">
        <div className={`${listStyles.skeleton} ${styles.skeletonHero}`} />
        <div className={listStyles.skeleton} />
        <div className={listStyles.skeleton} />
      </div>
    )
  }

  if (error || !detail) {
    return (
      <div>
        <p>
          <Link to="/app/groups">← Back to groups</Link>
        </p>
        <ErrorCard
          variant="plain"
          message={error ?? 'Group not found.'}
          onRetry={() => void reload()}
        />
      </div>
    )
  }

  const balanceClass =
    detail.netBalance > 0
      ? listStyles.positive
      : detail.netBalance < 0
        ? listStyles.negative
        : listStyles.neutral

  return (
    <div>
      <p className={styles.backLink}>
        <Link to="/app/groups">← Back to groups</Link>
      </p>

      <header className={styles.header}>
        <h1 className={styles.title}>{detail.name}</h1>
        <p className={`${listStyles.balance} ${balanceClass} ${styles.balanceLarge}`}>
          Your balance: {formatSignedBalance(detail.netBalance)}
        </p>
      </header>

      <BlockedActionBanner />

      <section className={styles.section}>
        <h2 className={styles.sectionTitle}>Members</h2>
        <div className={styles.memberChips}>
          {detail.members.map((member) => (
            <span key={member.id} className={styles.memberChip}>
              <span
                className={`${listStyles.avatar} ${styles.memberAvatar}`}
                aria-hidden
              >
                {initials(member.name)}
              </span>
              {member.name}
            </span>
          ))}
        </div>
      </section>

      {detail.balances.length > 0 ? (
        <section className={styles.section}>
          <h2 className={styles.sectionTitle}>Balances</h2>
          <ul className={listStyles.list}>
            {detail.balances.map((row, index) => (
              <li
                key={`${row.donorId}-${row.receiverId}-${index}`}
                className={`${listStyles.row} ${styles.staticRow}`}
              >
                <div className={listStyles.meta}>
                  <p className={listStyles.name}>
                    {row.donorName} → {row.receiverName}
                  </p>
                </div>
                <span className={listStyles.balance}>{formatInr(row.amount)}</span>
              </li>
            ))}
          </ul>
        </section>
      ) : null}

      <section>
        <h2 className={styles.sectionTitle}>Recent expenses</h2>
        {detail.expenses.length === 0 ? (
          <p className={styles.emptyText}>No expenses in this group yet.</p>
        ) : (
          <ul className={listStyles.list}>
            {detail.expenses.map((expense) => (
              <li key={expense.id} className={`${listStyles.row} ${styles.staticRow}`}>
                <div className={listStyles.meta}>
                  <p className={listStyles.name}>{expense.title}</p>
                  <p className={listStyles.subtitle}>
                    Paid by {expense.paidByName} · {formatTxnDate(expense.date)}
                  </p>
                </div>
                <span className={listStyles.balance}>{formatInr(expense.amount)}</span>
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  )
}
