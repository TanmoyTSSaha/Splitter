import type { TourBeat } from './tourBeats'
import styles from './TourCopyPanel.module.css'

type TourCopyPanelProps = {
  beat: TourBeat
  index: number
  /**
   * `pinned` panels start clipped because the scroll timeline wipes them in.
   * `stacked` panels stay visible so the mobile fallback reads without JS.
   */
  variant?: 'pinned' | 'stacked'
}

export function TourCopyPanel({ beat, index, variant = 'pinned' }: TourCopyPanelProps) {
  return (
    <div
      className={styles.panel}
      data-tour-copy={variant === 'pinned' ? index : undefined}
      data-variant={variant}
      data-side={beat.phoneSide === 'right' ? 'left' : 'right'}
    >
      <p className={styles.eyebrow}>{beat.eyebrow}</p>
      <h3 className={styles.title}>{beat.title}</h3>
      <p className={styles.body}>{beat.body}</p>
      <ul className={styles.points}>
        {beat.points.map((point) => (
          <li key={point}>{point}</li>
        ))}
      </ul>
    </div>
  )
}
