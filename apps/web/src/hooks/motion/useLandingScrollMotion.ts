import { useEffect, type RefObject } from 'react'
import { useReducedMotion } from '../useReducedMotion'
import { createMotionContext, isDesktopMotion, type MotionContext } from '../../lib/motion/scrollMotion'

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

export function useHowItWorksMotion(
  sectionRef: RefObject<HTMLElement | null>,
  stepsRef: RefObject<HTMLElement | null>,
  graphRef: RefObject<SVGSVGElement | null>,
): void {
  const reduced = useReducedMotion()

  useMotionEffect(
    reduced,
    (ctx) => {
      const sectionEl = sectionRef.current
      const stepsEl = stepsRef.current
      const graphEl = graphRef.current
      if (!sectionEl || !stepsEl || !graphEl) return

      const stepEls = stepsEl.querySelectorAll<HTMLElement>('[data-motion-step]')
      const connectors = graphEl.querySelectorAll<SVGLineElement>('[data-motion-connector]')
      const nodes = graphEl.querySelectorAll<SVGCircleElement>('[data-motion-node]')
      const { gsap } = ctx

      connectors.forEach((line) => {
        const length = line.getTotalLength()
        gsap.set(line, {
          strokeDasharray: length,
          strokeDashoffset: length,
        })
      })

      const setActiveStep = (index: number) => {
        stepEls.forEach((el, i) => {
          el.dataset.active = i === index ? 'true' : 'false'
        })
        nodes.forEach((node, i) => {
          node.dataset.active = i === index ? 'true' : 'false'
        })
      }

      if (isDesktopMotion()) {
        ctx.track(
          ctx.ScrollTrigger.create({
            trigger: sectionEl,
            start: 'top bottom',
            end: '+=120%',
            pin: true,
            scrub: 1,
            onUpdate: (self) => {
              const index = Math.min(stepEls.length - 1, Math.floor(self.progress * stepEls.length))
              setActiveStep(index)
              const drawProgress = Math.min(1, self.progress * 1.2)
              connectors.forEach((line, i) => {
                const length = line.getTotalLength()
                const segmentStart = i / connectors.length
                const segmentEnd = (i + 1) / connectors.length
                const local =
                  drawProgress <= segmentStart
                    ? 0
                    : drawProgress >= segmentEnd
                      ? 1
                      : (drawProgress - segmentStart) / (segmentEnd - segmentStart)
                gsap.set(line, { strokeDashoffset: length * (1 - local) })
              })
            },
          }),
        )
        setActiveStep(0)
        return
      }

      ctx.track(
        ctx.ScrollTrigger.create({
          trigger: sectionEl,
          start: 'top 70%',
          once: true,
          onEnter: () => {
            stepEls.forEach((el) => {
              el.dataset.active = 'true'
            })
            connectors.forEach((line) => {
              gsap.to(line, { strokeDashoffset: 0, duration: 0.8, ease: 'power2.out' })
            })
          },
        }),
      )
      setActiveStep(0)
    },
    [sectionRef, stepsRef, graphRef],
  )
}

export function useComparisonMotion(sectionRef: RefObject<HTMLElement | null>): void {
  const reduced = useReducedMotion()

  useMotionEffect(
    reduced,
    (ctx) => {
      const sectionEl = sectionRef.current
      if (!sectionEl) return
      const scanLine = sectionEl.querySelector<HTMLElement>('[data-motion-scan]')
      if (!scanLine) return
      const splitrCard = sectionEl.querySelector<HTMLElement>('[data-motion-splitr-card]')
      const { gsap } = ctx

      if (isDesktopMotion()) {
        ctx.track(
          ctx.ScrollTrigger.create({
            trigger: sectionEl,
            start: 'top 70%',
            once: true,
            onEnter: () => {
              gsap.fromTo(
                scanLine,
                { left: '0%' },
                { left: '100%', duration: 1.2, ease: 'power2.inOut' },
              )
              gsap.from(sectionEl.querySelectorAll('.comparison-yes'), {
                scale: 0.6,
                duration: 0.15,
                stagger: 0.05,
                delay: 0.4,
                ease: 'back.out(2)',
              })
            },
          }),
        )
        return
      }

      if (splitrCard) {
        ctx.track(
          ctx.ScrollTrigger.create({
            trigger: splitrCard,
            start: 'top 80%',
            once: true,
            onEnter: () => {
              gsap.fromTo(
                splitrCard,
                { boxShadow: '0 0 0 0 color-mix(in srgb, var(--color-accent) 0%, transparent)' },
                {
                  boxShadow: '0 0 0 4px color-mix(in srgb, var(--color-accent) 35%, transparent)',
                  duration: 0.4,
                  yoyo: true,
                  repeat: 1,
                },
              )
            },
          }),
        )
      }
    },
    [sectionRef],
  )
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
