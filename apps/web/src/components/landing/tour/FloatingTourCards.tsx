import styles from './FloatingTourCards.module.css'

/**
 * One pair of ambient stat cards per beat, in TOUR_BEATS order.
 * Index 0 is the centred hero set (cards flank the phone); the rest sit on
 * the copy side of the phone.
 */
const sets = [
  {
    top: { label: 'Monthly spend', value: '₹3,919', meta: 'Top 5 categories' },
    bottom: { label: 'Settled on UPI', value: '₹499', meta: 'Just now', accent: true },
  },
  {
    top: { label: 'Food spend', value: '₹4,200', meta: 'This month' },
    bottom: { label: 'Spending', chart: true },
  },
  {
    top: { label: 'You are owed', value: '₹2,400', meta: 'Across groups', accent: true },
    bottom: { label: 'Goa Trip', value: '₹840 owed', meta: '3 members' },
  },
  {
    top: { label: 'Interest accrued', value: '₹1,150', meta: 'Simple, 5%' },
    bottom: { label: 'Rahul', value: '75% repaid', meta: '₹4,500 left', progress: 0.75 },
  },
  {
    top: { label: 'Total spent', value: '₹85.1K', meta: 'All time' },
    bottom: { label: 'Monthly recap', value: 'July', meta: 'Ready to watch' },
  },
]

export function FloatingTourCards() {
  return (
    <div className={styles.wrap} data-floating-cards aria-hidden="true">
      {sets.map((set, index) => (
        <div key={index} className={styles.set} data-floating-set={index}>
          <div className={`${styles.card} ${styles.cardTop}`}>
            <span className={styles.cardLabel}>{set.top.label}</span>
            <strong className={set.top.accent ? styles.accent : undefined}>{set.top.value}</strong>
            <span className={styles.cardMeta}>{set.top.meta}</span>
          </div>
          <div className={`${styles.card} ${styles.cardBottom}`}>
            {'chart' in set.bottom && set.bottom.chart ? (
              <>
                <span className={styles.cardLabel}>{set.bottom.label}</span>
                <div className={styles.chart}>
                  <div className={styles.chartBar} style={{ height: '40%' }} />
                  <div className={styles.chartBar} style={{ height: '70%' }} />
                  <div className={styles.chartBar} style={{ height: '55%' }} />
                  <div className={styles.chartBar} style={{ height: '85%' }} />
                </div>
              </>
            ) : (
              <>
                <span className={styles.cardLabel}>{set.bottom.label}</span>
                <strong className={'accent' in set.bottom && set.bottom.accent ? styles.accent : undefined}>
                  {'value' in set.bottom ? set.bottom.value : null}
                </strong>
                <span className={styles.cardMeta}>
                  {'meta' in set.bottom ? set.bottom.meta : null}
                </span>
                {'progress' in set.bottom && set.bottom.progress != null ? (
                  <div className={styles.progress}>
                    <div
                      className={styles.progressFill}
                      style={{ width: `${set.bottom.progress * 100}%` }}
                    />
                  </div>
                ) : null}
              </>
            )}
          </div>
        </div>
      ))}
    </div>
  )
}
