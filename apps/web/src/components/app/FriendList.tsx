import { Link } from 'react-router-dom'
import { formatSignedBalance, type FriendSummary } from '../../lib/friendsData'
import { initials } from '../../lib/money'
import { PLAY_STORE_CTA_LABEL, PLAY_STORE_URL } from '../../constants/site'
import { trackInstallClick } from '../../lib/analytics'
import { Button } from '../Button'
import styles from './Groups.module.css'

type Props = {
  friends: FriendSummary[]
  loading?: boolean
}

function balanceClass(net: number): string {
  if (net > 0) return styles.positive
  if (net < 0) return styles.negative
  return styles.neutral
}

export function FriendList({ friends, loading }: Props) {
  if (loading) {
    return (
      <div className={styles.list} aria-busy="true" aria-label="Loading friends">
        <div className={styles.skeleton} />
        <div className={styles.skeleton} />
        <div className={styles.skeleton} />
      </div>
    )
  }

  if (friends.length === 0) {
    return (
      <section className={styles.empty}>
        <h2 className={styles.emptyTitle}>No friends yet</h2>
        <p className={styles.emptyBody}>Add friends in the Splitr app to track shared balances.</p>
        <Button
          as="a"
          href={PLAY_STORE_URL}
          target="_blank"
          rel="noopener noreferrer"
          onClick={() => trackInstallClick('friends_empty')}
        >
          {PLAY_STORE_CTA_LABEL}
        </Button>
      </section>
    )
  }

  return (
    <ul className={styles.list}>
      {friends.map((friend) => (
        <li key={friend.id}>
          <Link to={`/app/friends/${friend.id}`} className={styles.row}>
            <span className={styles.avatar} aria-hidden>
              {initials(friend.name)}
            </span>
            <div className={styles.meta}>
              <p className={styles.name}>{friend.name}</p>
              {friend.email ? <p className={styles.subtitle}>{friend.email}</p> : null}
            </div>
            <span className={`${styles.balance} ${balanceClass(friend.netBalance)}`}>
              {formatSignedBalance(friend.netBalance)}
            </span>
          </Link>
        </li>
      ))}
    </ul>
  )
}
