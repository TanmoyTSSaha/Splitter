import type { CSSProperties } from 'react'
import { BACK_RENDER } from './phoneGeometry'
import styles from './NothingPhone1Back.module.css'

const { imageW, imageH, bodyX, bodyY, bodyW, bodyH } = BACK_RENDER

/**
 * The render is cropped so its aluminium body maps onto the whole face — no
 * black margin, no seam at the rail.
 */
const renderStyle: CSSProperties = {
  width: `${(imageW / bodyW) * 100}%`,
  height: `${(imageH / bodyH) * 100}%`,
  left: `${(-bodyX / bodyW) * 100}%`,
  top: `${(-bodyY / bodyH) * 100}%`,
}

/**
 * The five physical Glyph channels, extracted from the render itself so each
 * overlay sits exactly on the channel it lights up. Bloom intensity comes from
 * --glyph-glow and the per-channel --glyph-pulse-N, both written straight to
 * the DOM by the scroll timeline.
 */
const GLYPHS = [0, 1, 2, 3, 4] as const

export function NothingPhone1Back() {
  return (
    <div className={styles.back}>
      <img className={styles.render} src="/phone/nothing-phone-1-back.png" alt="" style={renderStyle} />
      {GLYPHS.map((index) => (
        <img
          key={index}
          className={styles.glyph}
          src={`/phone/np1-glyph-${index}.png`}
          alt=""
          style={{ '--pulse': `var(--glyph-pulse-${index}, 1)` } as CSSProperties}
        />
      ))}
    </div>
  )
}
