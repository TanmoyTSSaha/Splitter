import { Link } from 'react-router-dom'
import { PLAY_STORE_CTA_LABEL, PLAY_STORE_URL } from '../../constants/site'
import { trackInstallClick } from '../../lib/analytics'
import { formatSignedBalance } from '../../lib/groupsData'
import type { GroupSummary } from '../../lib/groupsData'
import { initials } from '../../lib/money'
import { Button } from '../Button'
import styles from './Groups.module.css'

type Props = {
  groups: GroupSummary[]
  loading?: boolean
}

function balanceClass(net: number): string {
  if (net > 0) return styles.positive
  if (net < 0) return styles.negative
  return styles.neutral
}

export function GroupList({ groups, loading }: Props) {
  if (loading) {
    return (
      <div className={styles.list} aria-busy="true" aria-label="Loading groups">
        <div className={styles.skeleton} />
        <div className={styles.skeleton} />
        <div className={styles.skeleton} />
      </div>
    )
  }

  if (groups.length === 0) {
    return (
      <section className={styles.empty}>
        <h2 className={styles.emptyTitle}>No groups yet</h2>
        <p className={styles.emptyBody}>
          Create a group in the Splitr app to start splitting expenses with friends.
        </p>
        <Button
          as="a"
          href={PLAY_STORE_URL}
          target="_blank"
          rel="noopener noreferrer"
          onClick={() => trackInstallClick('groups_empty')}
        >
          {PLAY_STORE_CTA_LABEL}
        </Button>
      </section>
    )
  }

  return (
    <ul className={styles.list}>
      {groups.map((group) => (
        <li key={group.id}>
          <Link to={`/app/groups/${group.id}`} className={styles.row}>
            <span className={styles.avatar} aria-hidden>
              {initials(group.name)}
            </span>
            <div className={styles.meta}>
              <p className={styles.name}>{group.name}</p>
              <p className={styles.subtitle}>
                {group.memberCount} member{group.memberCount === 1 ? '' : 's'}
              </p>
            </div>
            <span className={`${styles.balance} ${balanceClass(group.netBalance)}`}>
              {formatSignedBalance(group.netBalance)}
            </span>
          </Link>
        </li>
      ))}
    </ul>
  )
}
