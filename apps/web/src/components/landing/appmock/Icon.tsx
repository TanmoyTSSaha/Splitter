import styles from './Icon.module.css'

export type IconVariant = 'filled' | 'outlined' | 'round'

const variantClass: Record<IconVariant, string> = {
  filled: styles.filled,
  outlined: styles.outlined,
  round: styles.round,
}

type IconProps = {
  /** Material Icons ligature name, e.g. `home`, `groups_2` */
  name: string
  /** Matches the Flutter `size:` argument in dp */
  size?: number
  color?: string
  variant?: IconVariant
  className?: string
}

export function Icon({ name, size = 24, color, variant = 'filled', className }: IconProps) {
  return (
    <span
      className={`${styles.icon} ${variantClass[variant]} ${className ?? ''}`}
      style={{ fontSize: `${size}px`, width: `${size}px`, height: `${size}px`, color }}
      aria-hidden="true"
    >
      {name}
    </span>
  )
}
