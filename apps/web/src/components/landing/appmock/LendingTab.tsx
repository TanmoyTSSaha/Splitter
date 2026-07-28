import { GlassCard } from './GlassCard'
import { GradientMesh } from './GradientMesh'
import { Icon } from './Icon'
import { Screen } from './Screen'
import styles from './LendingTab.module.css'

const loans = [
  {
    name: 'Rahul Verma',
    role: 'owes you',
    payable: '₹12000',
    remaining: '₹4500',
    due: 'Due Aug 12, 2026',
    principal: 52,
    interest: 10,
  },
  {
    name: 'Ananya Rao',
    role: 'you owe',
    payable: '₹8000',
    remaining: '₹6200',
    due: 'Due Sep 02, 2026',
    principal: 18,
    interest: 4,
  },
]

/** Mirrors lending_dashboard.dart */
export function LendingTab() {
  return (
    <Screen activeIndex={2}>
      <div className={styles.scroll}>
        <div className={styles.header}>
          <GradientMesh>
            <GlassCard opacity={0.12} className={styles.hero}>
              <p className={styles.tagline}>
                lending,
                <br />
                simplified.
              </p>
              <div className={styles.gapLg} />
              <p className={styles.heroLabel}>Total Net Position</p>
              <p className={styles.heroSub}>Active contracts only</p>
              <p className={styles.heroAmount}>₹ 5800</p>
              <span className={styles.heroChip}>You&apos;re in the green</span>
            </GlassCard>
          </GradientMesh>
          <div className={styles.gapLg} />
          <div className={styles.actionRow}>
            <div className={styles.actionCard}>
              <Icon name="arrow_outward" size={28} variant="round" />
              <span className={styles.actionLabel}>Lend Money</span>
            </div>
            <div className={styles.actionCard}>
              <Icon name="call_received" size={28} variant="round" />
              <span className={styles.actionLabel}>Borrow Money</span>
            </div>
          </div>
        </div>

        <div className={styles.pillBar}>
          <div className={styles.pillActive}>Active</div>
          <div className={styles.pillIdle}>Pending</div>
          <div className={styles.pillIdle}>Completed</div>
        </div>

        <div className={styles.list}>
          {loans.map((loan) => (
            <GlassCard key={loan.name} opacity={0.08} className={styles.loanCard}>
              <div className={styles.loanTop}>
                <div className={styles.loanWho}>
                  <div className={styles.avatar}>
                    <Icon name="person" size={22} variant="round" />
                  </div>
                  <div>
                    <p className={styles.loanName}>{loan.name}</p>
                    <p className={styles.loanRole}>{loan.role}</p>
                  </div>
                </div>
                <span className={styles.statusBadge}>ACTIVE</span>
              </div>
              <div className={styles.loanFigures}>
                <div>
                  <p className={styles.figLabel}>Total payable</p>
                  <p className={styles.figSmall}>{loan.payable}</p>
                </div>
                <div className={styles.figRight}>
                  <p className={styles.figLabel}>Remaining</p>
                  <p className={styles.figLarge}>{loan.remaining}</p>
                </div>
              </div>
              <div className={styles.progress}>
                <span style={{ flex: loan.principal, background: '#2e7d32' }} />
                <span style={{ flex: loan.interest, background: '#ffc107' }} />
                <span style={{ flex: 100 - loan.principal - loan.interest, background: '#d0d5dd' }} />
              </div>
              <div className={styles.dueRow}>
                <Icon name="calendar_today" size={14} color="var(--app-on-surface-muted)" variant="round" />
                <span>{loan.due}</span>
              </div>
            </GlassCard>
          ))}
        </div>
      </div>

      <div className={styles.fab}>New Contract</div>
    </Screen>
  )
}
