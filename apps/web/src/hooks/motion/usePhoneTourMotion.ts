import { useEffect, type RefObject } from 'react'
import type { ScrollTrigger as ScrollTriggerInstance } from 'gsap/ScrollTrigger'
import { BODY_H, BODY_W } from '../../components/landing/phone/phoneGeometry'
import { TOUR_BEATS } from '../../components/landing/tour/tourBeats'
import { computePhoneFit } from '../../lib/motion/phoneFit'
import { createMotionContext, isDesktopMotion, type MotionContext } from '../../lib/motion/scrollMotion'
import { useReducedMotion } from '../useReducedMotion'

/** Hero hold is longer so the centred intro can breathe. */
export const HERO_HOLD_PX = 420
const HOLD_PX = 240
const MOVE_PX = 380
const EDGE_GAP = 48
const GLYPH_COUNT = 5

const HOLD_DISTANCES = TOUR_BEATS.map((beat) => (beat.copy === 'hero' ? HERO_HOLD_PX : HOLD_PX))
const MOVE_COUNT = TOUR_BEATS.length - 1
export const TOUR_TOTAL_PX =
  HOLD_DISTANCES.reduce((sum, d) => sum + d, 0) + MOVE_COUNT * MOVE_PX

type Phase =
  | { kind: 'hold'; index: number }
  | { kind: 'move'; index: number; t: number }

/** Walks the per-beat hold / move ladder without allocating a table per frame. */
function phaseAt(progress: number): Phase {
  let cursor = Math.max(0, Math.min(1, progress)) * TOUR_TOTAL_PX
  for (let i = 0; i < TOUR_BEATS.length; i += 1) {
    const hold = HOLD_DISTANCES[i]
    if (cursor <= hold || i === TOUR_BEATS.length - 1) {
      return { kind: 'hold', index: i }
    }
    cursor -= hold
    if (i < MOVE_COUNT) {
      if (cursor <= MOVE_PX) {
        return { kind: 'move', index: i, t: cursor / MOVE_PX }
      }
      cursor -= MOVE_PX
    }
  }
  return { kind: 'hold', index: TOUR_BEATS.length - 1 }
}

function easeInOutCubic(t: number): number {
  return t < 0.5 ? 4 * t * t * t : 1 - (-2 * t + 2) ** 3 / 2
}

function easeOutCubic(t: number): number {
  return 1 - (1 - t) ** 3
}

function clamp01(value: number): number {
  return value < 0 ? 0 : value > 1 ? 1 : value
}

function ramp(value: number, from: number, to: number): number {
  return clamp01((value - from) / (to - from))
}

export function usePhoneTourMotion(sectionRef: RefObject<HTMLElement | null>): void {
  const reduced = useReducedMotion()

  useEffect(() => {
    const section = sectionRef.current
    if (!section || reduced) return

    let ctx: MotionContext | null = null
    let cancelled = false
    let pinTrigger: ScrollTriggerInstance | null = null

    void createMotionContext().then((motionCtx) => {
      if (cancelled) {
        motionCtx.cleanup()
        return
      }
      ctx = motionCtx
      const { gsap, ScrollTrigger } = motionCtx

      // Below the desktop breakpoint the beats are a plain stack; each one
      // just wipes in once as it enters.
      if (!isDesktopMotion()) {
        section.querySelectorAll<HTMLElement>('[data-tour-stack]').forEach((item) => {
          motionCtx.track(
            ScrollTrigger.create({
              trigger: item,
              start: 'top 80%',
              once: true,
              onEnter: () => {
                gsap.fromTo(
                  item,
                  { clipPath: 'inset(0 0 100% 0)', y: 24 },
                  { clipPath: 'inset(0 0 0% 0)', y: 0, duration: 0.7, ease: 'power3.out' },
                )
              },
            }),
          )
        })
        return
      }

      const pinEl = section.querySelector<HTMLElement>('[data-motion="tour-pin"]')
      const stage = section.querySelector<HTMLElement>('[data-motion="tour-stage"]')
      const mount = section.querySelector<HTMLElement>('[data-motion="phone-mount"]')
      const phone3d = section.querySelector<HTMLElement>('[data-motion="phone-3d"]')
      const mesh = section.querySelector<HTMLElement>('[data-motion="tour-mesh"]')
      const cardWrap = section.querySelector<HTMLElement>('[data-floating-cards]')
      const heroCopy = section.querySelector<HTMLElement>('[data-motion="hero-copy"]')
      if (!pinEl || !stage || !mount || !phone3d) return

      // Tab panels are keyed by tab index (0–3), not beat index.
      const panels = [0, 1, 2, 3].map((tab) =>
        section.querySelector<HTMLElement>(`[data-tab-panel="${tab}"]`),
      )
      const navItems = [0, 1, 2, 3].map((tab) =>
        Array.from(
          section.querySelectorAll<HTMLElement>(`[data-tab-panel="${tab}"] [data-nav-item]`),
        ),
      )
      const copyPanels = TOUR_BEATS.map((_, index) =>
        section.querySelector<HTMLElement>(`[data-tour-copy="${index}"]`),
      )
      const cardSets = TOUR_BEATS.map((_, index) =>
        section.querySelector<HTMLElement>(`[data-floating-set="${index}"]`),
      )

      gsap.set(mount, { x: 0, y: 0 })
      gsap.set(phone3d, { rotationX: 0, rotationY: 0, z: 0 })

      const setX = gsap.quickSetter(mount, 'x', 'px')
      const setY = gsap.quickSetter(mount, 'y', 'px')
      const setRotX = gsap.quickSetter(phone3d, 'rotationX', 'deg')
      const setRotY = gsap.quickSetter(phone3d, 'rotationY', 'deg')
      const setZ = gsap.quickSetter(phone3d, 'z', 'px')
      const setMeshScale = mesh ? gsap.quickSetter(mesh, 'scale') : null
      const setMeshOpacity = mesh ? gsap.quickSetter(mesh, 'opacity') : null

      let restX = 0
      let dropY = 0
      const measure = () => {
        const fit = computePhoneFit()
        mount.style.setProperty('--phone-fit', String(fit))
        const stageH = stage.clientHeight
        const stageW = stage.clientWidth
        const scaledH = BODY_H * fit
        const scaledW = BODY_W * fit
        restX = stageW / 2 - EDGE_GAP - scaledW / 2

        // Drop so the phone top sits near 55% of stage height; clamp so at
        // least 40% of the phone stays visible on short viewports.
        const unclamped = 0.55 * stageH - (stageH - scaledH) / 2
        const maxDrop = scaledH * 0.6
        dropY = Math.max(0, Math.min(unclamped, maxDrop))
      }

      const sideX = (beatIndex: number) => {
        const side = TOUR_BEATS[beatIndex].phoneSide
        if (side === 'center') return 0
        return side === 'right' ? restX : -restX
      }

      let visibleTab = -1
      const showTab = (tab: number) => {
        if (visibleTab === tab) return
        visibleTab = tab
        panels.forEach((panel, i) => {
          if (panel) panel.hidden = i !== tab
        })
      }

      const setNav = (tabIndex: number, fromItem: number, expand: number) => {
        const items = navItems[tabIndex]
        if (!items?.length) return
        items.forEach((item, i) => {
          const value = i === tabIndex ? expand : i === fromItem ? 1 - expand : 0
          item.style.setProperty('--expand', String(value))
        })
      }

      const setGlyphs = (glow: number, t: number) => {
        mount.style.setProperty('--glyph-glow', String(glow))
        for (let k = 0; k < GLYPH_COUNT; k += 1) {
          const local = clamp01((t - k * 0.05) / 0.72)
          const pulse = local <= 0 || local >= 1 ? 0.3 : 0.3 + 0.7 * Math.sin(Math.PI * local)
          mount.style.setProperty(`--glyph-pulse-${k}`, String(pulse))
        }
      }

      const setCards = (index: number, reveal: number) => {
        const set = cardSets[index]
        if (set) set.style.opacity = String(reveal)
      }

      const setCardSide = (beatIndex: number) => {
        if (cardWrap) cardWrap.dataset.side = TOUR_BEATS[beatIndex].phoneSide
      }

      const setTourCopy = (index: number, reveal: number) => {
        const panel = copyPanels[index]
        if (!panel) return
        panel.style.clipPath = `inset(0 0 ${(1 - reveal) * 100}% 0)`
        panel.style.opacity = String(reveal > 0 ? 1 : 0)
      }

      const setHeroCopy = (reveal: number) => {
        if (!heroCopy) return
        heroCopy.style.opacity = String(reveal)
        heroCopy.style.transform = `translateY(${(1 - reveal) * -28}px)`
        heroCopy.style.pointerEvents = reveal > 0.5 ? 'auto' : 'none'
      }

      const render = (progress: number) => {
        const phase = phaseAt(progress)

        if (setMeshScale) setMeshScale(1 + progress * 0.06)
        if (setMeshOpacity) setMeshOpacity(0.45 + progress * 0.2)

        if (phase.kind === 'hold') {
          const { index } = phase
          const beat = TOUR_BEATS[index]
          section.dataset.tourIndex = String(index)
          setX(sideX(index))
          setY(beat.phoneSide === 'center' ? dropY : 0)
          setRotX(0)
          setRotY(0)
          setZ(0)
          setGlyphs(0, 0)
          showTab(beat.tab)
          setNav(beat.tab, -1, 1)
          setCardSide(index)
          setHeroCopy(beat.copy === 'hero' ? 1 : 0)
          copyPanels.forEach((_, i) => {
            setTourCopy(i, i === index && TOUR_BEATS[i].copy !== 'hero' ? 1 : 0)
            setCards(i, i === index ? 1 : 0)
          })
          return
        }

        const { index, t } = phase
        const to = index + 1
        const fromBeat = TOUR_BEATS[index]
        const toBeat = TOUR_BEATS[to]
        section.dataset.tourIndex = String(index)

        const eased = easeInOutCubic(t)
        const fromX = sideX(index)
        const targetX = sideX(to)
        const direction = targetX > fromX ? 1 : -1
        const isHeroMove = fromBeat.copy === 'hero'

        setX(fromX + (targetX - fromX) * eased)

        if (isHeroMove) {
          // Rise + glide + slight lean; no back-face exposure.
          setY(dropY * (1 - eased))
          setRotY(direction * Math.sin(Math.PI * t) * -10)
          setRotX(Math.sin(Math.PI * t) * 0.05 * (180 / Math.PI))
          setZ(Math.sin(Math.PI * t) * -30)
          setGlyphs(0, 0)
          showTab(fromBeat.tab)
          setNav(fromBeat.tab, -1, 1)
        } else {
          setY(0)
          setRotY(direction * eased * 360)
          setRotX(Math.sin(Math.PI * t) * 0.1 * (180 / Math.PI))
          setZ(Math.sin(Math.PI * t) * -60)
          setGlyphs(Math.sin(Math.PI * t) ** 1.4, t)
          // Swapped while the back faces the camera, so no crossfade is needed.
          showTab(eased >= 0.5 ? toBeat.tab : fromBeat.tab)
          setNav(toBeat.tab, fromBeat.tab, easeOutCubic(ramp(t, 0.75, 1)))
          if (eased < 0.5) setNav(fromBeat.tab, -1, 1)
        }

        setCardSide(eased >= 0.5 ? to : index)

        copyPanels.forEach((_, i) => {
          if (i === index) {
            const reveal = 1 - ramp(t, 0, 0.35)
            if (fromBeat.copy === 'hero') {
              setHeroCopy(reveal)
              setTourCopy(i, 0)
            } else {
              setTourCopy(i, reveal)
            }
            setCards(i, reveal)
          } else if (i === to) {
            const reveal = ramp(t, 0.62, 1)
            if (toBeat.copy === 'hero') {
              setHeroCopy(reveal)
              setTourCopy(i, 0)
            } else {
              setTourCopy(i, reveal)
            }
            setCards(i, reveal)
          } else {
            setTourCopy(i, 0)
            setCards(i, 0)
            if (TOUR_BEATS[i].copy === 'hero' && i !== index && i !== to) {
              setHeroCopy(0)
            }
          }
        })
      }

      measure()

      pinTrigger = ScrollTrigger.create({
        trigger: pinEl,
        start: 'top top',
        end: `+=${TOUR_TOTAL_PX}`,
        pin: true,
        pinSpacing: true,
        scrub: 0.6,
        anticipatePin: 1,
        invalidateOnRefresh: true,
        onRefresh: () => {
          measure()
          render(pinTrigger?.progress ?? 0)
        },
        onUpdate: (self) => render(self.progress),
      })
      motionCtx.track(pinTrigger)

      render(0)
      requestAnimationFrame(() => ScrollTrigger.refresh())
    })

    return () => {
      cancelled = true
      pinTrigger?.kill()
      ctx?.cleanup()
    }
  }, [sectionRef, reduced])
}
