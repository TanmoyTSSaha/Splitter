import { useRef } from 'react'
import { Button } from '../components/Button'
import { PLAY_STORE_CTA_LABEL, PLAY_STORE_URL } from '../constants/site'
import { trackInstallClick } from '../lib/analytics'
import { useNotFoundMotion } from '../hooks/motion/useNotFoundMotion'
import { usePageMeta } from '../hooks/usePageMeta'
import styles from './NotFoundPage.module.css'

export function NotFoundPage() {
  const digitsRef = useRef<HTMLDivElement>(null)
  const actionsRef = useRef<HTMLDivElement>(null)

  useNotFoundMotion(digitsRef, actionsRef)

  usePageMeta(
    'Page not found',
    'This Splitr page could not be found.',
    '/404',
    { noIndex: true },
  )

  return (
    <div className={styles.page}>
      <div className={styles.inner}>
        <div ref={digitsRef} className={styles.code} aria-hidden="true">
          <span data-motion-digit>4</span>
          <span data-motion-digit>0</span>
          <span data-motion-digit>4</span>
        </div>
        <h1 className={styles.title} tabIndex={-1}>
          Page not found
        </h1>
        <p className={styles.body}>
          The link may be broken or the page may have moved. Head home or get the app on Google Play.
        </p>
        <div ref={actionsRef} className={styles.actions}>
          <Button as="a" href="/">
            Home
          </Button>
          <Button
            as="a"
            variant="ghost"
            href={PLAY_STORE_URL}
            target="_blank"
            rel="noopener noreferrer"
            onClick={() => trackInstallClick('404')}
          >
            {PLAY_STORE_CTA_LABEL}
          </Button>
        </div>
      </div>
    </div>
  )
}
