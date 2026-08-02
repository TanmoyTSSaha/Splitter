import { useEffect, type RefObject } from 'react'
import { loadGsap } from '../lib/motion/gsap'
import { useReducedMotion } from './useReducedMotion'

/** Staggered fade + rise for the CTAs / badge / tertiary links under the hero heading. */
export function useHeroCopyMotion(
  refs: Array<RefObject<HTMLElement | null>>,
): void {
  const reduced = useReducedMotion()

  useEffect(() => {
    const elements = refs
      .map((ref) => ref.current)
      .filter((el): el is HTMLElement => el !== null)

    if (!elements.length) return

    if (reduced) {
      elements.forEach((el) => {
        el.style.opacity = '1'
        el.style.transform = 'none'
      })
      return
    }

    let cancelled = false

    void loadGsap().then(({ gsap }) => {
      if (cancelled) return
      gsap.fromTo(
        elements,
        { opacity: 0, y: 16 },
        {
          opacity: 1,
          y: 0,
          duration: 0.55,
          stagger: 0.08,
          delay: 0.55,
          ease: 'power3.out',
        },
      )
    })

    return () => {
      cancelled = true
    }
  }, [reduced, refs])
}
