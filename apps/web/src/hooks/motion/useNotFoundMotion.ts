import { useEffect, type RefObject } from 'react'
import { useReducedMotion } from '../useReducedMotion'
import { createMotionContext } from '../../lib/motion/scrollMotion'

export function useNotFoundMotion(
  digitsRef: RefObject<HTMLElement | null>,
  actionsRef: RefObject<HTMLElement | null>,
): void {
  const reduced = useReducedMotion()

  useEffect(() => {
    const digits = digitsRef.current
    const actions = actionsRef.current
    if (!digits || reduced) return

    const digitEls = digits.querySelectorAll<HTMLElement>('[data-motion-digit]')
    if (!digitEls.length) return

    let ctx: Awaited<ReturnType<typeof createMotionContext>> | null = null
    let cancelled = false
    const tweens: Array<{ kill: () => void }> = []

    const onEnter = () => {
      if (!ctx) return
      ctx.gsap.to(digitEls, {
        x: 0,
        y: 0,
        duration: 0.3,
        ease: 'power2.out',
      })
    }

    void createMotionContext().then((motionCtx) => {
      if (cancelled) {
        motionCtx.cleanup()
        return
      }

      ctx = motionCtx
      const { gsap } = motionCtx

      digitEls.forEach((digit) => {
        tweens.push(
          gsap.to(digit, {
            x: () => gsap.utils.random(-12, 12),
            y: () => gsap.utils.random(-8, 8),
            duration: 4,
            repeat: -1,
            yoyo: true,
            ease: 'sine.inOut',
          }),
        )
      })

      actions?.addEventListener('mouseenter', onEnter)
    })

    return () => {
      cancelled = true
      actions?.removeEventListener('mouseenter', onEnter)
      tweens.forEach((tween) => tween.kill())
      ctx?.cleanup()
    }
  }, [reduced, digitsRef, actionsRef])
}
