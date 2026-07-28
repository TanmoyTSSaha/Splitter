import styles from './StepIcon.module.css'

type StepId = 'group' | 'split' | 'settle'

type Props = {
  id: StepId
}

const common = {
  width: 20,
  height: 20,
  viewBox: '0 0 24 24',
  fill: 'none',
  stroke: 'currentColor',
  strokeWidth: 1.75,
  strokeLinecap: 'round' as const,
  strokeLinejoin: 'round' as const,
  'aria-hidden': true,
}

export function StepIcon({ id }: Props) {
  return (
    <span className={styles.wrap}>
      {id === 'group' ? (
        <svg {...common}>
          <circle cx="9" cy="8" r="3" />
          <circle cx="16" cy="9" r="2.5" />
          <path d="M4 19c0-2.5 2.2-4 5-4s5 1.5 5 4" />
          <path d="M14 19c0-1.8 1.4-3 3.5-3" />
        </svg>
      ) : null}
      {id === 'split' ? (
        <svg {...common}>
          <path d="M6 6h12" />
          <path d="M12 6v12" />
          <path d="M8 12h8" />
          <path d="M9 18h6" />
        </svg>
      ) : null}
      {id === 'settle' ? (
        <svg {...common}>
          <path d="M7 12h10" />
          <path d="M14 8l4 4-4 4" />
          <circle cx="7" cy="12" r="5" />
        </svg>
      ) : null}
    </span>
  )
}
