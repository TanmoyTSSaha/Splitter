import { useRef } from 'react'
import { useTrustStripMotion } from '../../hooks/motion/useLandingScrollMotion'
import { TrustIcon } from './TrustIcon'
import styles from './TrustStrip.module.css'

const items = [
  { label: 'UPI-friendly settle up', icon: 'upi' as const },
  { label: 'Your data encrypted', icon: 'lock' as const },
  { label: 'Free core splits', icon: 'check' as const },
  { label: 'Made for India', icon: 'india' as const },
]

export function TrustStrip() {
  const sectionRef = useRef<HTMLElement>(null)
  useTrustStripMotion(sectionRef)

  return (
    <section ref={sectionRef} className={styles.strip} id="trust" aria-label="Trust highlights">
      <div className={`container ${styles.inner}`}>
        {items.map((item) => (
          <div key={item.label} className={styles.item}>
            <span className={styles.iconWrap} data-motion="trust-icon" aria-hidden="true">
              <TrustIcon id={item.icon} />
            </span>
            <span className={styles.label}>{item.label}</span>
          </div>
        ))}
      </div>
    </section>
  )
}
