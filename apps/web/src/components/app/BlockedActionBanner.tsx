import { PLAY_STORE_CTA_LABEL, PLAY_STORE_URL } from '../../constants/site'
import { trackInstallClick } from '../../lib/analytics'
import { Button } from '../Button'
import styles from './BlockedActionBanner.module.css'

export function BlockedActionBanner() {
  return (
    <div className={styles.banner} role="status">
      <h2 className={styles.title}>Available in the app</h2>
      <p className={styles.body}>
        Add expenses, settle up, and manage your account in the Splitr mobile app.
      </p>
      <div className={styles.actions}>
        <Button
          as="a"
          href={PLAY_STORE_URL}
          target="_blank"
          rel="noopener noreferrer"
          onClick={() => trackInstallClick('app_blocked_banner')}
        >
          {PLAY_STORE_CTA_LABEL}
        </Button>
        <Button as="a" variant="ghost" href="splitr://">
          Open in app
        </Button>
      </div>
    </div>
  )
}
