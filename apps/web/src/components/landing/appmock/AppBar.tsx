import { Icon } from './Icon'
import styles from './AppBar.module.css'

/**
 * Mirrors the shared `_buildAppBar` used by Home, Groups and Lending:
 * transparent, no leading, titleSpacing 16, `Splitr.` in Albra 28/700,
 * NotificationBellButton (28dp icon + 9dp accent dot) then avatar r20,
 * with a 16dp trailing gap.
 */
export function AppBar({ showBellDot = true }: { showBellDot?: boolean }) {
  return (
    <div className={styles.bar}>
      <span className={styles.title}>Splitr.</span>
      <div className={styles.actions}>
        <div className={styles.bell}>
          <Icon name="notifications" size={28} variant="outlined" />
          {showBellDot ? <span className={styles.bellDot} /> : null}
        </div>
        <div className={styles.avatar}>
          <Icon name="person" size={24} variant="round" />
        </div>
      </div>
    </div>
  )
}
