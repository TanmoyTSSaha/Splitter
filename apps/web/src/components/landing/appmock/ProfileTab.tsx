import { GlassCard } from './GlassCard'
import { GradientMesh } from './GradientMesh'
import { Icon } from './Icon'
import { Screen } from './Screen'
import styles from './ProfileTab.module.css'

const badges = [
  { name: 'Social Circle', icon: 'groups', unlocked: true },
  { name: 'Loan Starter', icon: 'handshake', unlocked: true },
  { name: 'Goal Setter', icon: 'flag', unlocked: false },
  { name: 'Splitter', icon: 'call_split', unlocked: false },
]

const menu = [
  { icon: 'person_outline', title: 'Personal Details', subtitle: 'Name, email, phone number' },
  { icon: 'people_outline', title: 'Friends', subtitle: 'Manage your connections' },
  { icon: 'insights', title: 'Expense Insights', subtitle: 'Trends, unusual spends, settle-up health' },
  { icon: 'calendar_month', title: 'Monthly Recap', subtitle: 'Your spending wrapped, once a month' },
]

/** Mirrors profile_screen.dart — no AppBar, hero card then badges then menu */
export function ProfileTab() {
  return (
    <Screen activeIndex={3} showAppBar={false}>
      <div className={styles.scroll}>
        <GradientMesh className={styles.heroMesh}>
          <div className={styles.gapSm} />
          <div className={styles.avatarFrame}>
            <span className={styles.avatarGlow} />
            <div className={styles.avatar}>
              <Icon name="person" size={64} variant="round" />
            </div>
            <span className={styles.proBadge}>
              <Icon name="workspace_premium" size={16} variant="round" />
            </span>
            <span className={styles.editBadge}>
              <Icon name="edit" size={15} variant="round" />
            </span>
          </div>
          <div className={styles.gapMd} />
          <GlassCard opacity={0.12} className={styles.identity}>
            <p className={styles.name}>Tanu Saha</p>
            <p className={styles.tier}>PRO MEMBER</p>
            <div className={styles.gapMd} />
            <div className={styles.chipRow}>
              <div className={styles.chip}>
                <span className={styles.chipLabel}>TOTAL SPENT: </span>
                <span className={styles.chipValue}>₹85.1K</span>
              </div>
              <div className={styles.chip}>
                <span className={styles.chipLabel}>TOTAL RECEIVED: </span>
                <span className={styles.chipValue}>₹749</span>
              </div>
            </div>
          </GlassCard>
        </GradientMesh>

        <div className={styles.gapXl} />
        <h2 className={styles.sectionSerif}>Achievements</h2>
        <div className={styles.gapSm} />
        <div className={styles.badgeRow}>
          {badges.map((badge) => (
            <div key={badge.name} className={styles.badge}>
              <div className={badge.unlocked ? styles.badgeDiscUnlocked : styles.badgeDisc}>
                <Icon
                  name={badge.icon}
                  size={32}
                  variant="round"
                  color={badge.unlocked ? 'var(--app-accent)' : 'var(--app-on-surface-muted)'}
                />
              </div>
              <span className={badge.unlocked ? styles.badgeName : styles.badgeNameLocked}>
                {badge.name}
              </span>
            </div>
          ))}
        </div>

        <div className={styles.gapLg} />
        <p className={styles.sectionLabel}>ACCOUNT INFO</p>
        <div className={styles.gapSm} />
        <GlassCard opacity={0.09} className={styles.menuCard}>
          {menu.map((row, index) => (
            <div key={row.title}>
              <div className={styles.tile}>
                <div className={styles.tileIcon}>
                  <Icon name={row.icon} size={20} variant="round" />
                </div>
                <div className={styles.tileBody}>
                  <p className={styles.tileTitle}>{row.title}</p>
                  <p className={styles.tileSub}>{row.subtitle}</p>
                </div>
                <Icon
                  name="chevron_right"
                  size={20}
                  color="var(--app-on-surface-muted)"
                  variant="round"
                />
              </div>
              {index < menu.length - 1 ? <div className={styles.divider} /> : null}
            </div>
          ))}
        </GlassCard>
      </div>
    </Screen>
  )
}
