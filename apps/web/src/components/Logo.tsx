import { Link } from 'react-router-dom'
import styles from './Logo.module.css'

export function Logo() {
  return (
    <Link to="/" className={styles.logo} aria-label="Splitr home">
      Splitr<span className={styles.dot}>.</span>
    </Link>
  )
}
