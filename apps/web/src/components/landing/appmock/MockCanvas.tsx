import type { ReactNode } from 'react'
import tokens from './appTokens.module.css'
import styles from './MockCanvas.module.css'

/**
 * Reference device: Pixel-class 1080x2400 at DPR 2.625 => 411x914 logical dp.
 * Authoring at these exact dimensions means every Flutter dp value maps to
 * one px, so paddings, radii and type scale keep their real ratios. The whole
 * canvas is then scaled to whatever width the phone screen viewport gives it.
 */
export const MOCK_WIDTH = 411
export const MOCK_HEIGHT = 914

export function MockCanvas({ children }: { children: ReactNode }) {
  return (
    <div className={`${tokens.root} ${styles.canvas}`} aria-hidden="true">
      {children}
    </div>
  )
}
