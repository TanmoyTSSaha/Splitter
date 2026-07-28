import { useRef } from 'react'
import { Button } from '../../Button'
import { PlayStoreBadge } from '../../PlayStoreBadge'
import { useHeroCopyMotion } from '../../../hooks/useHeroCopyMotion'
import { useHeroMotion } from '../../../hooks/useHeroMotion'
import { trackInstallClick, trackSignInClick } from '../../../lib/analytics'
import styles from './HeroCopy.module.css'

type HeroCopyProps = {
  /**
   * `pinned` sits centred above the phone in the desktop tour stage.
   * `stacked` is the mobile / reduced-motion static hero.
   */
  variant?: 'pinned' | 'stacked'
}

export function HeroCopy({ variant = 'pinned' }: HeroCopyProps) {
  const eyebrowRef = useRef<HTMLParagraphElement>(null)
  const titleRef = useRef<HTMLHeadingElement>(null)
  const ctasRef = useRef<HTMLDivElement>(null)
  const tertiaryRef = useRef<HTMLParagraphElement>(null)

  useHeroMotion(titleRef, eyebrowRef)
  useHeroCopyMotion([ctasRef, tertiaryRef])

  return (
    <div
      className={styles.wrap}
      data-variant={variant}
      data-hero-copy
      data-motion="hero-copy"
    >
      <p ref={eyebrowRef} className={styles.eyebrow}>
        Expense splitting for friends &amp; groups
      </p>
      <h1 ref={titleRef} id="hero-heading" className={styles.title}>
        Split. Track. Settle.
      </h1>
      <p className={styles.subtitle}>
        Personal finance home — monthly spend, transactions, and goals in one app built for India.
      </p>
      <div ref={ctasRef} className={styles.ctas}>
        <PlayStoreBadge onClick={() => trackInstallClick('hero')} />
        <Button as="a" href="/app" variant="ghost" onClick={() => trackSignInClick('hero')}>
          Sign in
        </Button>
      </div>
      <p ref={tertiaryRef} className={styles.tertiary}>
        <a href="#pricing">Pro pricing</a>
        <span aria-hidden="true"> · </span>
        <a href="/contact">Contact</a>
      </p>
    </div>
  )
}
