import styles from './Account.module.css'

type Props = {
  label: string
  hint?: string
  href: string
  external?: boolean
}

export function SettingsRow({
  label,
  hint = 'Available in the app',
  href,
  external = href.startsWith('splitr://'),
}: Props) {
  return (
    <li>
      <a
        className={styles.row}
        href={href}
        {...(external ? { target: '_blank', rel: 'noopener noreferrer' } : {})}
      >
        <span>
          <span className={styles.label}>{label}</span>
          <span className={styles.hint}>{hint}</span>
        </span>
        <span className={styles.chevron} aria-hidden>
          →
        </span>
      </a>
    </li>
  )
}
