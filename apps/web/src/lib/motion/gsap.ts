import type { gsap as GsapType } from 'gsap'
import type { ScrollTrigger as ScrollTriggerType } from 'gsap/ScrollTrigger'

export type GsapBundle = {
  gsap: typeof GsapType
  ScrollTrigger: typeof ScrollTriggerType
}

let bundlePromise: Promise<GsapBundle> | null = null

export function loadGsap(): Promise<GsapBundle> {
  if (!bundlePromise) {
    bundlePromise = Promise.all([import('gsap'), import('gsap/ScrollTrigger')]).then(
      ([gsapModule, scrollModule]) => {
        const gsap = gsapModule.default
        const ScrollTrigger = scrollModule.ScrollTrigger
        gsap.registerPlugin(ScrollTrigger)
        return { gsap, ScrollTrigger }
      },
    )
  }
  return bundlePromise
}
