import { Link, useParams } from 'react-router-dom'
import { BlockedActionBanner } from '../../components/app/BlockedActionBanner'
import { ErrorCard } from '../../components/app/ErrorCard'
import { useFriendDetail } from '../../hooks/useFriendDetail'
import { usePageMeta } from '../../hooks/usePageMeta'
import { PLAY_STORE_URL } from '../../constants/site'
import { trackInstallClick } from '../../lib/analytics'
import { formatInr, formatTxnDate, initials } from '../../lib/money'
import { formatSignedBalance } from '../../lib/friendsData'
import listStyles from '../../components/app/Groups.module.css'
import styles from './DetailPage.module.css'

function balanceLabel(net: number): string {
  if (net > 0) return 'Owes you'
  if (net < 0) return 'You owe'
  return 'Settled up'
}

export function FriendDetailPage() {
  const { friendId } = useParams<{ friendId: string }>()
  const { detail, loading, error, reload } = useFriendDetail(friendId)

  usePageMeta(
    detail?.name ?? 'Friend',
    'Friend details on Splitr web.',
    friendId ? `/app/friends/${friendId}` : '/app/friends',
    { noIndex: true },
  )

  if (loading) {
    return (
      <div aria-busy="true" aria-label="Loading friend">
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
          <Link to="/app/friends">← Back to friends</Link>
        </p>
        <ErrorCard
          variant="plain"
          message={error ?? 'Friend not found.'}
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
        <Link to="/app/friends">← Back to friends</Link>
      </p>

      <header className={styles.profileCard}>
        <span className={`${listStyles.avatar} ${styles.profileAvatar}`} aria-hidden>
          {initials(detail.name)}
        </span>
        <h1 className={styles.profileTitle}>{detail.name}</h1>
        {detail.email ? <p className={styles.profileEmail}>{detail.email}</p> : null}
        <p className={styles.balanceCaption}>{balanceLabel(detail.netBalance)}</p>
        <p className={`${listStyles.balance} ${balanceClass} ${styles.balanceHero}`}>
          {formatSignedBalance(detail.netBalance)}
        </p>
      </header>

      <BlockedActionBanner />

      {detail.groupBreakdown.length > 0 ? (
        <section className={styles.section}>
          <h2 className={styles.sectionTitle}>By group</h2>
          <ul className={listStyles.list}>
            {detail.groupBreakdown.map((row) => (
              <li
                key={`${row.groupId}-${row.amount}`}
                className={`${listStyles.row} ${styles.staticRow}`}
              >
                <div className={listStyles.meta}>
                  <p className={listStyles.name}>{row.groupName}</p>
                  <p className={listStyles.subtitle}>
                    {row.amount >= 0 ? 'They owe you' : 'You owe them'}
                  </p>
                </div>
                <span
                  className={`${listStyles.balance} ${row.amount >= 0 ? listStyles.positive : listStyles.negative}`}
                >
                  {formatSignedBalance(row.amount)}
                </span>
              </li>
            ))}
          </ul>
        </section>
      ) : (
        <p className={styles.emptySection}>No shared group balances with this friend.</p>
      )}

      <section>
        <h2 className={styles.sectionTitle}>Shared expenses</h2>
        {detail.transactions.length === 0 ? (
          <p className={styles.emptyText}>No shared expenses found.</p>
        ) : (
          <>
            <ul className={listStyles.list}>
              {detail.transactions.map((txn) => (
                <li key={txn.id} className={`${listStyles.row} ${styles.staticRow}`}>
                  <div className={listStyles.meta}>
                    <p className={listStyles.name}>{txn.title}</p>
                    <p className={listStyles.subtitle}>
                      {txn.groupName} · {formatTxnDate(txn.date)}
                    </p>
                  </div>
                  <span className={listStyles.balance}>{formatInr(txn.amount)}</span>
                </li>
              ))}
            </ul>
            <p className={styles.footnote}>
              Showing latest 15.{' '}
              <a
                href={PLAY_STORE_URL}
                target="_blank"
                rel="noopener noreferrer"
                onClick={() => trackInstallClick('friend_detail_app')}
              >
                See all in app
              </a>
            </p>
          </>
        )}
      </section>
    </div>
  )
}
