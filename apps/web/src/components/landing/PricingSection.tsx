import { useRef } from 'react'
import { trackInstallClick } from '../../lib/analytics'
import { usePricingMotion } from '../../hooks/motion/useLandingScrollMotion'
import { PlayStoreBadge } from '../PlayStoreBadge'
import styles from './PricingSection.module.css'

const plans = [
  {
    name: 'Monthly',
    price: '₹89',
    period: '/month',
    note: 'Billed through Google Play',
    motionKey: 'monthly-card',
  },
  {
    name: 'Yearly',
    price: '₹799',
    period: '/year',
    note: 'Save vs monthly · billed through Google Play',
    featured: true,
    motionKey: 'annual-card',
  },
]

export function PricingSection() {
  const sectionRef = useRef<HTMLElement>(null)
  usePricingMotion(sectionRef)

  return (
    <section ref={sectionRef} className={styles.section} id="pricing" aria-labelledby="pricing-heading">
      <div className="container">
        <h2 id="pricing-heading" className={styles.heading}>
          Splitr Pro
        </h2>
        <p className={styles.sub}>
          Advanced tools like receipt OCR and exports. Subscribe in the app — checkout on web is not
          available in v1.
        </p>
        <div className={styles.grid}>
          {plans.map((plan) => (
            <article
              key={plan.name}
              className={`${styles.card} ${plan.featured ? styles.featured : ''}`}
              data-motion={plan.motionKey}
            >
              <h3>
                {plan.name}
                {plan.featured ? <span className={styles.bestValue}>Best value</span> : null}
              </h3>
              <p className={styles.price}>
                <span>{plan.price}</span>
                <span className={styles.period}>{plan.period}</span>
              </p>
              <p className={styles.note}>{plan.note}</p>
            </article>
          ))}
        </div>
        <div className={styles.storeCta}>
          <PlayStoreBadge onClick={() => trackInstallClick('pricing')} />
        </div>
      </div>
    </section>
  )
}
