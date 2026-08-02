import { useEffect, useRef } from 'react'
import { PhoneChassis } from '../phone/PhoneChassis'
import { usePhoneTourMotion, HERO_HOLD_PX } from '../../../hooks/motion/usePhoneTourMotion'
import { useMediaQuery } from '../../../hooks/useMediaQuery'
import { useReducedMotion } from '../../../hooks/useReducedMotion'
import { FloatingTourCards } from './FloatingTourCards'
import { HeroCopy } from './HeroCopy'
import { TourCopyPanel } from './TourCopyPanel'
import { TOUR_BEATS } from './tourBeats'
import styles from './PhoneTourSection.module.css'

const PRODUCT_BEATS = TOUR_BEATS.map((beat, index) => ({ beat, index })).filter(
  ({ beat }) => beat.copy !== 'hero',
)

export function PhoneTourSection() {
  const sectionRef = useRef<HTMLElement>(null)
  const isDesktop = useMediaQuery('(min-width: 1024px)')
  const reduced = useReducedMotion()

  usePhoneTourMotion(sectionRef)

  // Keeping the pinned stage out of the tree below the breakpoint also keeps
  // the back render and the five glyph masks off the wire on phones.
  const showPinnedStage = isDesktop && !reduced

  // Land at the top of the page once, so the centred half-phone framing is
  // what the visitor sees first — not a mid-scroll restore from a prior visit.
  useEffect(() => {
    if (window.scrollY > 0) {
      window.scrollTo(0, 0)
    }
  }, [])

  return (
    <section
      ref={sectionRef}
      id="hero"
      className={styles.section}
      aria-labelledby="hero-heading"
      data-phone-tour
    >
      {/*
        Nav / footer Features links still point at #features. Park the marker
        at the end of the hero hold so a click lands on the Home beat.
      */}
      <span
        id="features"
        className={styles.featuresAnchor}
        style={{ top: `${HERO_HOLD_PX}px` }}
        aria-hidden="true"
      />

      {showPinnedStage ? (
        <div className={styles.pin} data-motion="tour-pin">
          <div className={styles.stage} data-motion="tour-stage">
            <div className={styles.mesh} data-motion="tour-mesh" aria-hidden="true" />

            <div className={styles.copyLayer}>
              <HeroCopy variant="pinned" />
              {PRODUCT_BEATS.map(({ beat, index }) => (
                <TourCopyPanel key={beat.eyebrow} beat={beat} index={index} />
              ))}
            </div>

            <div className={styles.phoneMount} data-motion="phone-mount" aria-hidden="true">
              <FloatingTourCards />
              <div className={styles.phoneScale}>
                <div className={styles.phone3d} data-motion="phone-3d">
                  <PhoneChassis />
                </div>
              </div>
            </div>
          </div>
        </div>
      ) : (
        <>
          <div className={styles.staticHero}>
            <HeroCopy variant="stacked" />
            <div className={styles.staticPhone} aria-hidden="true">
              <PhoneChassis initialTab={0} frontOnly width={260} />
            </div>
          </div>
          <div className={styles.stack}>
            {PRODUCT_BEATS.map(({ beat, index }) => (
              <div key={beat.eyebrow} className={styles.stackItem} data-tour-stack={index}>
                <div className={styles.stackPhone} aria-hidden="true">
                  <PhoneChassis initialTab={beat.tab} frontOnly width={260} />
                </div>
                <TourCopyPanel beat={beat} index={index} variant="stacked" />
              </div>
            ))}
          </div>
        </>
      )}
    </section>
  )
}
