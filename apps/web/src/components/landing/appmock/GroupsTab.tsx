import { GlassCard } from './GlassCard'
import { GradientMesh } from './GradientMesh'
import { Icon } from './Icon'
import { Screen } from './Screen'
import styles from './GroupsTab.module.css'

const groups = [
  { name: 'Flatmates', color: '#1e1e1e', icon: 'home' },
  { name: 'Goa Trip', color: '#448aff', icon: 'group' },
]

const activity = [
  { title: 'Goa stay', meta: 'Mon, Jul 13', sub: 'You paid', icon: 'group', amount: '₹4200' },
  { title: 'Groceries', meta: 'Sun, Jul 12', sub: 'You owe', icon: 'receipt_long', amount: '₹680' },
]

/** Mirrors group_screen.dart */
export function GroupsTab() {
  return (
    <Screen activeIndex={1}>
      <div className={styles.scroll}>
        <GradientMesh>
          <GlassCard opacity={0.1} className={styles.hero}>
            <p className={styles.tagline}>
              money matters,
              <br />
              simplified.
            </p>
            <div className={styles.gapLg} />
            <div className={styles.statRow}>
              <div className={styles.statCard}>
                <span className={`${styles.decor} ${styles.decorAccent}`} />
                <p className={styles.statTitle}>YOU ARE OWED</p>
                <p className={`${styles.statAmount} ${styles.accent}`}>₹2400</p>
                <div className={styles.statSub}>
                  <Icon name="trending_up" size={14} color="var(--app-grey)" />
                  <span>from 2 groups</span>
                </div>
              </div>
              <div className={styles.statCard}>
                <span className={`${styles.decor} ${styles.decorPrimary}`} />
                <p className={styles.statTitle}>YOU OWE</p>
                <p className={`${styles.statAmount} ${styles.primary}`}>₹680</p>
                <div className={styles.statSub}>
                  <Icon name="trending_down" size={14} color="var(--app-grey)" />
                  <span>to 1 group</span>
                </div>
              </div>
            </div>
          </GlassCard>
        </GradientMesh>

        <div className={styles.pillBar}>
          <div className={styles.pillActive}>Group Expense</div>
          <div className={styles.pillIdle}>Trip Expense</div>
        </div>

        <div className={styles.inset}>
          <div className={styles.sectionHead}>
            <span className={styles.sectionLabel}>ACTIVE GROUPS</span>
            <div className={styles.sectionRight}>
              <span className={styles.countBadge}>2</span>
              <span className={styles.link}>Show archived</span>
            </div>
          </div>
          <div className={styles.gapMd} />
        </div>

        <div className={styles.carousel}>
          {groups.map((group) => (
            <div key={group.name} className={styles.groupCard} style={{ background: group.color }}>
              <div className={styles.groupTop}>
                <span className={styles.groupDotWrap}>
                  <span className={styles.groupDot} />
                </span>
                <Icon name={group.icon} size={24} color="rgba(255,255,255,0.5)" variant="round" />
              </div>
              <div>
                <p className={styles.groupKicker}>MONTHLY</p>
                <p className={styles.groupName}>{group.name}</p>
              </div>
            </div>
          ))}
          <div className={styles.addCard}>
            <span className={styles.addCircle}>
              <Icon name="add" size={24} color="rgba(24,197,149,0.9)" />
            </span>
            <span className={styles.addLabel}>
              <Icon name="groups_2" size={18} color="var(--app-accent)" variant="round" />
              New Group
            </span>
          </div>
        </div>

        <div className={styles.inset}>
          <div className={styles.gapLg} />
          <div className={styles.sectionHead}>
            {/* Not upper-cased in group_screen.dart, unlike the section above */}
            <span className={styles.sectionLabel}>Recent Activity</span>
            <span className={styles.action}>VIEW ALL</span>
          </div>
          <div className={styles.gapMd} />
          {activity.map((item) => (
            <div key={item.title} className={styles.txn}>
              <div className={styles.txnIcon}>
                <Icon name={item.icon} size={16} variant="round" />
              </div>
              <div className={styles.txnBody}>
                <div className={styles.txnTitleRow}>
                  <span className={styles.txnTitle}>{item.title}</span>
                  <span className={styles.groupBadge}>Group</span>
                </div>
                <div className={styles.txnMetaRow}>
                  <span className={styles.txnMeta}>{item.meta}</span>
                  <span className={styles.txnPipe}>|</span>
                  <span className={styles.txnMeta}>{item.sub}</span>
                </div>
              </div>
              <Icon name="north_east" size={16} color="var(--app-primary)" />
              <span className={styles.txnAmount}>{item.amount}</span>
            </div>
          ))}
        </div>
      </div>

      <div className={styles.fab}>
        <Icon name="add" size={24} color="var(--app-on-accent)" />
        <span>New Group</span>
      </div>
    </Screen>
  )
}
