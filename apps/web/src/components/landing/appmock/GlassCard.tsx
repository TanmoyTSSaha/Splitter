import type { CSSProperties, ReactNode } from 'react'
import styles from './GlassCard.module.css'

type GlassCardProps = {
  children: ReactNode
  /** Flutter `opacity` arg — white overlay alpha (default 0.08) */
  opacity?: number
  /** Flutter `borderRadius` arg in dp */
  radius?: number
  className?: string
  style?: CSSProperties
}

/**
 * Mirrors glass_card.dart: white fill at `opacity`, a topLeft→bottomRight
 * white gradient at opacity+0.03 → opacity-0.02, a 1dp white border at 0.10,
 * and a 15dp backdrop blur.
 */
export function GlassCard({
  children,
  opacity = 0.08,
  radius = 16,
  className,
  style,
}: GlassCardProps) {
  return (
    <div
      className={`${styles.card} ${className ?? ''}`}
      style={
        {
          '--glass-a': opacity,
          '--glass-a-bump': opacity + 0.03,
          '--glass-a-dip': Math.max(0, opacity - 0.02),
          borderRadius: `${radius}px`,
          ...style,
        } as CSSProperties
      }
    >
      {children}
    </div>
  )
}
