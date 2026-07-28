import { Link } from 'react-router-dom'
import { PLAY_STORE_CTA_LABEL, PLAY_STORE_URL } from '../../constants/site'
import { trackInstallClick, trackSignInClick } from '../../lib/analytics'
import { Button } from '../Button'
import styles from './DeepLinkPreview.module.css'

type Props = {
  eyebrow: string
  title: string
  subtitle: string
  error?: string
  loading?: boolean
  isAuthenticated: boolean
  appDeepLink: string
  webHref?: string
  installLocation: string
}

export function DeepLinkPreviewCard({
  eyebrow,
  title,
  subtitle,
  error,
  loading,
  isAuthenticated,
  appDeepLink,
  webHref,
  installLocation,
}: Props) {
  if (loading) {
    return <div className={styles.skeleton} aria-busy="true" aria-label="Loading invite" />
  }

  return (
    <article className={styles.card}>
      <p className={styles.eyebrow}>{eyebrow}</p>
      <h1 className={styles.title}>{title}</h1>
      <p className={styles.subtitle}>{subtitle}</p>

      {error ? (
        <p className={styles.error} role="alert">
          {error}
        </p>
      ) : null}

      <div className={styles.actions}>
        {error ? (
          <Button
            as="a"
            href={PLAY_STORE_URL}
            target="_blank"
            rel="noopener noreferrer"
            onClick={() => trackInstallClick(`${installLocation}_error`)}
          >
            {PLAY_STORE_CTA_LABEL}
          </Button>
        ) : isAuthenticated ? (
          <>
            <Button as="a" href={appDeepLink}>
              Open in app
            </Button>
            {webHref ? (
              <Button as="a" variant="ghost" href={webHref}>
                View on web
              </Button>
            ) : null}
          </>
        ) : (
          <>
            <Button
              as="a"
              href={PLAY_STORE_URL}
              target="_blank"
              rel="noopener noreferrer"
              onClick={() => trackInstallClick(installLocation)}
            >
              {PLAY_STORE_CTA_LABEL}
            </Button>
            <Button as="a" variant="ghost" href="/app" onClick={() => trackSignInClick(installLocation)}>
              Sign in
            </Button>
          </>
        )}
      </div>

      <p className={styles.back}>
        <Link to="/">Back to home</Link>
      </p>
    </article>
  )
}
