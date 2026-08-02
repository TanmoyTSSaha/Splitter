import { useEffect, useState } from 'react'
import { useLocation } from 'react-router-dom'
import { loadGsap } from '../../lib/motion/gsap'
import { useReducedMotion } from '../../hooks/useReducedMotion'
import styles from './IntroOverlay.module.css'

const STORAGE_KEY = 'splitr_intro_seen'
const FALLBACK_MS = 2800

export function IntroOverlay() {
  const { pathname } = useLocation()
  const reduced = useReducedMotion()
  const [active, setActive] = useState(() => {
    if (typeof window === 'undefined') return false
    if (window.location.pathname !== '/') return false
    return sessionStorage.getItem(STORAGE_KEY) !== '1'
  })

  useEffect(() => {
    if (pathname !== '/' && active) {
      setActive(false)
    }
  }, [pathname, active])

  useEffect(() => {
    if (!active) return

    if (reduced) {
      sessionStorage.setItem(STORAGE_KEY, '1')
      setActive(false)
      return
    }

    let completed = false
    let cancelled = false
    let timelineKill: (() => void) | null = null

    const dismiss = () => {
      if (completed) return
      completed = true
      sessionStorage.setItem(STORAGE_KEY, '1')
      setActive(false)
    }

    const fallback = window.setTimeout(dismiss, FALLBACK_MS)

    void loadGsap()
      .then(({ gsap }) => {
        if (cancelled || completed) return

        const reveal = document.querySelector(`.${styles.reveal}`)
        const wordmark = document.querySelector(`.${styles.wordmark}`)

        if (!reveal || !wordmark) {
          dismiss()
          return
        }

        const tl = gsap.timeline({
          defaults: { ease: 'power2.out' },
          onComplete: dismiss,
        })

        tl.fromTo(
          wordmark,
          { opacity: 0, scale: 0.96 },
          { opacity: 1, scale: 1, duration: 0.5 },
        ).fromTo(
          reveal,
          { clipPath: 'circle(0% at 50% 50%)' },
          { clipPath: 'circle(150% at 50% 50%)', duration: 0.6 },
          '-=0.15',
        )

        timelineKill = () => tl.kill()
      })
      .catch(() => dismiss())

    return () => {
      cancelled = true
      window.clearTimeout(fallback)
      timelineKill?.()
    }
  }, [active, reduced])

  if (!active) return null

  return (
    <div className={styles.overlay} aria-hidden="true">
      <div className={styles.reveal}>
        <p className={styles.wordmark}>Splitr</p>
      </div>
    </div>
  )
}
