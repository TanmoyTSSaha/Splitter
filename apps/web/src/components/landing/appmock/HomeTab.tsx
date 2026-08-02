import { GlassCard } from './GlassCard'
import { GradientMesh } from './GradientMesh'
import { Icon } from './Icon'
import { Screen } from './Screen'
import styles from './HomeTab.module.css'

const spendCards = [
  { category: 'Entertainment', amount: '₹1080', icon: 'local_activity', color: '#ff9800' },
  { category: 'Food', amount: '₹339', icon: 'restaurant', color: '#18c595' },
  { category: 'Transport', amount: '₹2500', icon: 'directions_car', color: '#9e9e9e' },
]

const transactions = [
  { title: 'Dinner at Social', meta: 'Tue, Jul 14', sub: 'Food', icon: 'restaurant', amount: '₹840', credit: false },
  { title: 'Metro recharge', meta: 'Tue, Jul 14', sub: 'Transport', icon: 'receipt_long', amount: '₹200', credit: false },
  { title: 'Goa stay', meta: 'Mon, Jul 13', sub: 'You paid', icon: 'group', amount: '₹4200', credit: false, group: true },
  { title: 'Settlement payment', meta: 'Mon, Jul 13', sub: 'You owe', icon: 'swap_horiz', amount: '₹499', credit: true, group: true },
]

/** Mirrors home_screen.dart */
export function HomeTab() {
  return (
    <Screen activeIndex={0}>
      <div className={styles.scroll}>
        <GradientMesh>
          <GlassCard opacity={0.12} className={styles.hero}>
            <p className={styles.tagline}>
              money matters,
              <br />
              simplified.
            </p>
            <div className={styles.gapLg} />
            <h2 className={styles.sectionSerif}>Monthly Spend</h2>
            <div className={styles.gapMd} />
            <div className={styles.spendRow}>
              {spendCards.map((card) => (
                <div key={card.category} className={styles.spendCard}>
                  <Icon name={card.icon} size={28} color={card.color} variant="round" />
                  <div>
                    <p className={styles.spendCategory}>{card.category}</p>
                    <p className={styles.spendAmount}>{card.amount}</p>
                  </div>
                  <div className={styles.miniBars}>
                    <span style={{ height: 10, background: card.color, opacity: 0.3 }} />
                    <span style={{ height: 20, background: card.color, opacity: 0.5 }} />
                    <span style={{ height: 15, background: card.color, opacity: 0.4 }} />
                    <span style={{ height: 30, background: card.color }} />
                  </div>
                </div>
              ))}
            </div>
          </GlassCard>
        </GradientMesh>

        <div className={styles.gapLg} />

        <div className={styles.sectionHead}>
          <h2 className={styles.sectionSerif}>Transactions</h2>
          <span className={styles.action}>VIEW ALL</span>
        </div>
        <div className={styles.gapMd} />
        {transactions.map((txn) => (
          <div key={txn.title} className={styles.txn}>
            <div className={styles.txnIcon}>
              <Icon name={txn.icon} size={16} variant="round" />
            </div>
            <div className={styles.txnBody}>
              <div className={styles.txnTitleRow}>
                <span className={styles.txnTitle}>{txn.title}</span>
                {txn.group ? <span className={styles.groupBadge}>Group</span> : null}
              </div>
              <div className={styles.txnMetaRow}>
                <span className={styles.txnMeta}>{txn.meta}</span>
                <span className={styles.txnPipe}>|</span>
                <span className={styles.txnMeta}>{txn.sub}</span>
              </div>
            </div>
            <Icon
              name={txn.credit ? 'south_west' : 'north_east'}
              size={16}
              color={txn.credit ? 'var(--app-accent)' : 'var(--app-primary)'}
            />
            <span
              className={styles.txnAmount}
              style={{ color: txn.credit ? 'var(--app-accent)' : 'var(--app-primary)' }}
            >
              {txn.amount}
            </span>
          </div>
        ))}

        <div className={styles.gapLg} />

        <div className={styles.sectionHead}>
          <div>
            <h2 className={styles.sectionSerif}>Cash Flow</h2>
            <p className={styles.sectionSub}>Money leaving your wallet</p>
          </div>
          <div className={styles.toggle}>
            <span className={styles.toggleOff}>Spend</span>
            <span className={styles.toggleOn}>Flow</span>
          </div>
        </div>
        <div className={styles.gapMd} />
        <div className={styles.flowCard}>
          <div className={styles.flowRow}>
            <div className={styles.flowIcon}>
              <Icon name="arrow_upward" size={24} variant="round" />
            </div>
            <div>
              <p className={styles.flowLabel}>Total Outflow</p>
              <p className={styles.flowAmount}>₹8420</p>
            </div>
          </div>
        </div>
      </div>

      <div className={styles.fab}>
        <Icon name="add" size={24} />
      </div>
    </Screen>
  )
}
