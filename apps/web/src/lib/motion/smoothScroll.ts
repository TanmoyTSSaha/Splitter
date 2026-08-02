import { loadGsap } from './gsap'

/**
 * Lenis drives the native scroll position, so ScrollTrigger pins, the Nav's
 * window.scrollY listener and anchor links all keep working. Driving Lenis
 * from the GSAP ticker (rather than its own rAF) keeps scroll updates and
 * scrubbed timelines on the same frame.
 */
export function initSmoothScroll(): () => void {
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    return () => {}
  }

  let dispose: (() => void) | null = null
  let cancelled = false

  void Promise.all([import('lenis'), loadGsap()]).then(([{ default: Lenis }, { gsap, ScrollTrigger }]) => {
    if (cancelled) return

    const lenis = new Lenis({ autoRaf: false, syncTouch: true })
    const raf = (time: number) => lenis.raf(time * 1000)

    lenis.on('scroll', ScrollTrigger.update)
    gsap.ticker.add(raf)
    gsap.ticker.lagSmoothing(0)

    dispose = () => {
      gsap.ticker.remove(raf)
      gsap.ticker.lagSmoothing(500, 33)
      lenis.destroy()
    }
  })

  return () => {
    cancelled = true
    dispose?.()
  }
}
