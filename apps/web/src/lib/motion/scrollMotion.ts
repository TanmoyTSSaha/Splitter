import type { ScrollTrigger } from 'gsap/ScrollTrigger'
import { loadGsap } from './gsap'

export function isDesktopMotion(): boolean {
  return window.matchMedia('(min-width: 1024px)').matches
}

export type MotionContext = Awaited<ReturnType<typeof createMotionContext>>

export async function createMotionContext() {
  const { gsap, ScrollTrigger } = await loadGsap()
  const triggers: ScrollTrigger[] = []
  return {
    gsap,
    ScrollTrigger,
    track(trigger: ScrollTrigger) {
      triggers.push(trigger)
      return trigger
    },
    cleanup() {
      triggers.forEach((trigger) => trigger.kill())
    },
  }
}
