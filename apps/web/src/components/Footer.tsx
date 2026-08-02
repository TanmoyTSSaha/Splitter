import { Link } from 'react-router-dom'
import { LEGAL_ROUTES, SUPPORT_EMAIL } from '../constants/site'
import { trackInstallClick } from '../lib/analytics'
import { Logo } from './Logo'
import { PlayStoreBadge } from './PlayStoreBadge'
import styles from './Footer.module.css'

const productLinks = [
  { href: '/#features', label: 'Features' },
  { href: '/#pricing', label: 'Pricing' },
  { href: '/#faq', label: 'FAQ' },
  { href: '/#pricing', label: 'Splitr Pro' },
]

const legalLinks = [
  { to: LEGAL_ROUTES.privacy, label: 'Privacy Policy' },
  { to: LEGAL_ROUTES.terms, label: 'Terms of Service' },
  { to: LEGAL_ROUTES.refund, label: 'Refund Policy' },
  { to: LEGAL_ROUTES.cancellation, label: 'Cancellation Policy' },
  { to: LEGAL_ROUTES.accountDeletion, label: 'Account deletion' },
]

export function Footer() {
  return (
    <footer className={`site-footer ${styles.footer}`}>
      <div className={`container ${styles.grid}`}>
        <div>
          <Logo />
          <p className={styles.tagline}>Split expenses with friends. Track, settle, and stay on top of shared money.</p>
        </div>
        <div>
          <h3 className={styles.heading}>Product</h3>
          <ul className={styles.list}>
            {productLinks.map((item) => (
              <li key={item.label}>
                <a href={item.href}>{item.label}</a>
              </li>
            ))}
          </ul>
        </div>
        <div>
          <h3 className={styles.heading}>Legal</h3>
          <ul className={styles.list}>
            {legalLinks.map((item) => (
              <li key={item.to}>
                <Link to={item.to}>{item.label}</Link>
              </li>
            ))}
          </ul>
        </div>
        <div>
          <h3 className={styles.heading}>Contact</h3>
          <ul className={styles.list}>
            <li>
              <a href={`mailto:${SUPPORT_EMAIL}`}>{SUPPORT_EMAIL}</a>
            </li>
            <li>
              <Link to={LEGAL_ROUTES.contact}>Contact page</Link>
            </li>
          </ul>
          <PlayStoreBadge
            className={styles.playBadge}
            onClick={() => trackInstallClick('footer')}
          />
        </div>
      </div>
      <div className={`container ${styles.bottom}`}>
        <p>© {new Date().getFullYear()} Splitr. All rights reserved.</p>
      </div>
    </footer>
  )
}
