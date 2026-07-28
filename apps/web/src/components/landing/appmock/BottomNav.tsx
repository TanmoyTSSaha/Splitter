import { useEffect, useRef } from 'react'
import { Icon } from './Icon'
import { NAV_ITEMS } from './navItems'
import styles from './BottomNav.module.css'

/**
 * Mirrors animated_glass_bottom_nav_bar.dart. The per-item expansion is
 * exposed as a `--expand` custom property so the scroll timeline can scrub it
 * directly on the DOM without re-rendering React every frame.
 */
export function BottomNav({ activeIndex }: { activeIndex: number }) {
  const rootRef = useRef<HTMLDivElement>(null)

  // The label clip animates `width: label-width * expand`, so the intrinsic
  // label width has to be measured once the webfont has settled.
  useEffect(() => {
    const root = rootRef.current
    if (!root) return

    // offsetWidth rather than a client rect, because the whole canvas sits
    // under a CSS scale.
    const measure = () => {
      if (!root.offsetWidth) return
      root.querySelectorAll<HTMLElement>('[data-nav-label]').forEach((label) => {
        label.parentElement?.style.setProperty('--label-w', `${label.offsetWidth}px`)
      })
    }

    measure()
    let cancelled = false
    void document.fonts?.ready.then(() => {
      if (!cancelled) measure()
    })

    // Screens that start hidden have no layout box, so the first measurement
    // is deferred until the tour reveals them. The bar's own width is fixed,
    // so this can't feed back into itself.
    const observer = new ResizeObserver(measure)
    observer.observe(root)

    return () => {
      cancelled = true
      observer.disconnect()
    }
  }, [])

  return (
    <div ref={rootRef} className={styles.bar} data-mock-nav>
      {NAV_ITEMS.map((item, index) => (
        <div
          key={item.label}
          className={styles.item}
          data-nav-item={index}
          style={{ '--expand': index === activeIndex ? 1 : 0 } as React.CSSProperties}
        >
          <div className={styles.iconSlot}>
            <div className={styles.iconCircle} />
            <span className={styles.iconOutline}>
              <Icon name={item.icon} size={26} variant={item.outlineVariant} />
            </span>
            <span className={styles.iconFilled}>
              <Icon name={item.icon} size={26} variant={item.filledVariant} />
            </span>
          </div>
          <div className={styles.labelClip}>
            <span className={styles.label} data-nav-label>
              {item.label}
            </span>
          </div>
        </div>
      ))}
    </div>
  )
}
