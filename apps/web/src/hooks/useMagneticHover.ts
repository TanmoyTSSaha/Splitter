import { useEffect, type RefObject } from 'react'
import { useReducedMotion } from './useReducedMotion'

export function useMagneticHover(
  ref: RefObject<HTMLElement | null>,
  maxOffset = 4,
  enabled = true,
): void {
  const reduced = useReducedMotion()

  useEffect(() => {
    const el = ref.current
    if (!el || reduced || !enabled) return

    const desktop = window.matchMedia('(min-width: 1024px)').matches
    if (!desktop) return

    const onMove = (event: MouseEvent) => {
      const rect = el.getBoundingClientRect()
      const centerX = rect.left + rect.width / 2
      const centerY = rect.top + rect.height / 2
      const dx = (event.clientX - centerX) / (rect.width / 2)
      const dy = (event.clientY - centerY) / (rect.height / 2)
      const clampedX = Math.max(-1, Math.min(1, dx))
      const clampedY = Math.max(-1, Math.min(1, dy))
      el.style.transform = `translate(${clampedX * maxOffset}px, ${clampedY * maxOffset}px)`
    }

    const onLeave = () => {
      el.style.transform = ''
    }

    el.addEventListener('mousemove', onMove)
    el.addEventListener('mouseleave', onLeave)

    return () => {
      el.removeEventListener('mousemove', onMove)
      el.removeEventListener('mouseleave', onLeave)
      el.style.transform = ''
    }
  }, [ref, maxOffset, reduced, enabled])
}
