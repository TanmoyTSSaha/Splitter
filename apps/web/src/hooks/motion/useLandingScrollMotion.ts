import { useEffect, type RefObject } from 'react'
import { useReducedMotion } from '../useReducedMotion'
import { createMotionContext, type MotionContext } from '../../lib/motion/scrollMotion'

function useMotionEffect(
  reduced: boolean,
  setup: (ctx: MotionContext) => void,
  deps: unknown[],
): void {
  useEffect(() => {
    if (reduced) return

    let ctx: MotionContext | null = null
    let cancelled = false

    void createMotionContext().then((motionCtx) => {
      if (cancelled) {
        motionCtx.cleanup()
        return
      }
      ctx = motionCtx
      setup(motionCtx)
    })

    return () => {
      cancelled = true
      ctx?.cleanup()
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps -- caller controls deps
  }, [reduced, ...deps])
}

export function usePricingMotion(sectionRef: RefObject<HTMLElement | null>): void {
  const reduced = useReducedMotion()

  useMotionEffect(
    reduced,
    (ctx) => {
      const sectionEl = sectionRef.current
      const annual = sectionEl?.querySelector<HTMLElement>('[data-motion="annual-card"]')
      if (!sectionEl || !annual) return
      const monthly = sectionEl.querySelector<HTMLElement>('[data-motion="monthly-card"]')
      const { gsap } = ctx

      ctx.track(
        ctx.ScrollTrigger.create({
          trigger: sectionEl,
          start: 'top 60%',
          once: true,
          onEnter: () => {
            if (monthly) {
              gsap.fromTo(monthly, { y: 16 }, { y: 0, duration: 0.35, ease: 'power2.out' })
            }
            gsap.fromTo(annual, { y: 24 }, { y: -8, duration: 0.4, ease: 'back.out(1.4)' })
          },
        }),
      )
    },
    [sectionRef],
  )
}

export function useTrustStripMotion(sectionRef: RefObject<HTMLElement | null>): void {
  const reduced = useReducedMotion()

  useMotionEffect(
    reduced,
    (ctx) => {
      const sectionEl = sectionRef.current
      if (!sectionEl) return
      const icons = sectionEl.querySelectorAll<HTMLElement>('[data-motion="trust-icon"]')
      if (!icons.length) return
      const { gsap } = ctx

      ctx.track(
        ctx.ScrollTrigger.create({
          trigger: sectionEl,
          start: 'top 50%',
          once: true,
          onEnter: () => {
            gsap.from(icons, {
              scale: 1.15,
              duration: 0.2,
              stagger: 0.08,
              ease: 'steps(3)',
            })
          },
        }),
      )
    },
    [sectionRef],
  )
}

export function useFinalCtaMotion(sectionRef: RefObject<HTMLElement | null>): void {
  const reduced = useReducedMotion()

  useMotionEffect(
    reduced,
    (ctx) => {
      const sectionEl = sectionRef.current
      if (!sectionEl) return
      const { gsap } = ctx

      ctx.track(
        ctx.ScrollTrigger.create({
          trigger: sectionEl,
          start: 'top 60%',
          once: true,
          onEnter: () => {
            gsap.fromTo(
              sectionEl,
              { clipPath: 'inset(100% 0 0 0)' },
              { clipPath: 'inset(0 0 0 0)', duration: 0.6, ease: 'power2.out' },
            )
            sectionEl.dataset.inView = 'true'
          },
          onLeave: () => {
            sectionEl.dataset.inView = 'false'
          },
          onEnterBack: () => {
            sectionEl.dataset.inView = 'true'
          },
        }),
      )
    },
    [sectionRef],
  )
}
