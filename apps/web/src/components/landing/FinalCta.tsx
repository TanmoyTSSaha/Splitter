import { useRef } from 'react'
import { trackInstallClick } from '../../lib/analytics'
import { useFinalCtaMotion } from '../../hooks/motion/useLandingScrollMotion'
import { PlayStoreBadge } from '../PlayStoreBadge'
import styles from './FinalCta.module.css'

export function FinalCta() {
  const sectionRef = useRef<HTMLElement>(null)
  useFinalCtaMotion(sectionRef)

  return (
    <section ref={sectionRef} className={styles.section} id="download" aria-labelledby="download-heading">
      <div className={`container ${styles.inner}`}>
        <h2 id="download-heading" className={styles.heading}>
          Ready to split smarter?
        </h2>
        <p className={styles.sub}>Download Splitr on Android and start tracking shared expenses today.</p>
        <PlayStoreBadge
          className={styles.playBadge}
          onClick={() => trackInstallClick('final_cta')}
        />
      </div>
    </section>
  )
}
