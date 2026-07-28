import { Icon } from './Icon'
import styles from './StatusBar.module.css'

/** Neutral Android status bar — no carrier or notification clutter. */
export function StatusBar() {
  return (
    <div className={styles.bar}>
      <span className={styles.clock}>9:41</span>
      <div className={styles.icons}>
        <Icon name="signal_cellular_alt" size={16} />
        <Icon name="wifi" size={16} />
        <Icon name="battery_full" size={16} />
      </div>
    </div>
  )
}
