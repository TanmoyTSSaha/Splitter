import type { ReactNode } from 'react'
import { Button } from '../Button'
import styles from './ErrorCard.module.css'

type Props = {
  message: ReactNode
  onRetry?: () => void
  variant?: 'card' | 'plain'
  className?: string
}

export function ErrorCard({ message, onRetry, variant = 'card', className = '' }: Props) {
  return (
    <div
      role="alert"
      className={`${styles.root} ${variant === 'plain' ? styles.plain : styles.card} ${className}`.trim()}
    >
      <p className={styles.message}>{message}</p>
      {onRetry ? (
        <Button type="button" onClick={onRetry}>
          Retry
        </Button>
      ) : null}
    </div>
  )
}
