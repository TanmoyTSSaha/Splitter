import { useEffect, type RefObject } from 'react'
import { loadGsap } from '../lib/motion/gsap'
import { useReducedMotion } from './useReducedMotion'

/**
 * Fade + rise entrance for the centred hero heading, matching the NexusBank
 * GIF reference rather than the earlier left-to-right clip wipe.
 */
export function useHeroMotion(
  titleRef: RefObject<HTMLElement | null>,
  eyebrowRef?: RefObject<HTMLElement | null>,
): void {
  const reduced = useReducedMotion()

  useEffect(() => {
    const title = titleRef.current
    if (!title) return

    const eyebrow = eyebrowRef?.current ?? null

    if (reduced) {
      title.style.opacity = '1'
      title.style.transform = 'none'
      if (eyebrow) {
        eyebrow.style.opacity = '1'
        eyebrow.style.transform = 'none'
      }
      return
    }

    let cancelled = false

    void loadGsap().then(({ gsap }) => {
      if (cancelled) return

      if (eyebrow) {
        gsap.fromTo(
          eyebrow,
          { opacity: 0, y: 18 },
          { opacity: 1, y: 0, duration: 0.55, ease: 'power3.out', delay: 0.08 },
        )
      }

      gsap.fromTo(
        title,
        { opacity: 0, y: 28 },
        { opacity: 1, y: 0, duration: 0.7, ease: 'power3.out', delay: 0.18 },
      )
    })

    return () => {
      cancelled = true
    }
  }, [reduced, titleRef, eyebrowRef])
}
