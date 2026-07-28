import styles from './TrustIcon.module.css'

type IconId = 'upi' | 'lock' | 'check' | 'india'

type Props = {
  id: IconId
}

const common = {
  width: 22,
  height: 22,
  viewBox: '0 0 24 24',
  fill: 'none',
  stroke: 'currentColor',
  strokeWidth: 1.75,
  strokeLinecap: 'round' as const,
  strokeLinejoin: 'round' as const,
  'aria-hidden': true,
}

export function TrustIcon({ id }: Props) {
  switch (id) {
    case 'upi':
      return (
        <svg {...common} className={styles.icon}>
          <path d="M7 7h10v10H7z" />
          <path d="M9 12h6" />
          <path d="M12 9v6" />
        </svg>
      )
    case 'lock':
      return (
        <svg {...common} className={styles.icon}>
          <rect x="5" y="11" width="14" height="10" rx="2" />
          <path d="M8 11V8a4 4 0 0 1 8 0v3" />
        </svg>
      )
    case 'check':
      return (
        <svg {...common} className={styles.icon}>
          <circle cx="12" cy="12" r="9" />
          <path d="M8 12.5 10.8 15 16 9" />
        </svg>
      )
    case 'india':
      return (
        <svg {...common} className={styles.icon}>
          <circle cx="12" cy="12" r="9" />
          <path d="M5.5 12h13" />
          <path d="M12 5.5a6.5 6.5 0 0 1 0 13" />
        </svg>
      )
  }
}
