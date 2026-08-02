import { forwardRef, type AnchorHTMLAttributes } from 'react'
import { PLAY_STORE_URL } from '../constants/site'
import styles from './PlayStoreBadge.module.css'

type Props = {
  className?: string
  size?: 'default' | 'compact'
  onClick?: () => void
} & Omit<AnchorHTMLAttributes<HTMLAnchorElement>, 'href' | 'target' | 'rel' | 'children'>

/** Official Google Play “Get it on Google Play” badge (Partner Marketing Hub asset). */
export const PlayStoreBadge = forwardRef<HTMLAnchorElement, Props>(function PlayStoreBadge(
  { className = '', size = 'default', onClick, ...rest },
  ref,
) {
  return (
    <a
      ref={ref}
      className={`${styles.badge} ${size === 'compact' ? styles.compact : ''} ${className}`.trim()}
      href={PLAY_STORE_URL}
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Get Splitr on Google Play"
      onClick={onClick}
      {...rest}
    >
      <img
        className={styles.img}
        src="/badges/google-play-badge.png"
        alt="Get it on Google Play"
        width={646}
        height={250}
        decoding="async"
      />
    </a>
  )
})
