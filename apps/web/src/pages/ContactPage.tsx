import { Link } from 'react-router-dom'
import { Button } from '../components/Button'
import { LegalPageLayout } from '../components/LegalPageLayout'
import { CONTACT_EMAIL, LEGAL_ROUTES, OPERATOR_LINE, SUPPORT_EMAIL } from '../constants/site'
import { usePageMeta } from '../hooks/usePageMeta'
import styles from './ContactPage.module.css'

export function ContactPage() {
  usePageMeta('Contact', 'Get help with Splitr.', LEGAL_ROUTES.contact)

  return (
    <LegalPageLayout>
      <h1>Contact</h1>
      <p>{OPERATOR_LINE}</p>
      <p>
        We respond on a best-effort basis during India business hours. Include your account email,
        device model, and a clear description of your issue.
      </p>

      <div className={styles.cards}>
        <div className={styles.card}>
          <h2>Support</h2>
          <p>App issues, billing, account help, and data requests.</p>
          <Button as="a" href={`mailto:${SUPPORT_EMAIL}`}>
            {SUPPORT_EMAIL}
          </Button>
        </div>
        <div className={styles.card}>
          <h2>General</h2>
          <p>Partnerships and other enquiries.</p>
          <Button as="a" href={`mailto:${CONTACT_EMAIL}`} variant="ghost">
            {CONTACT_EMAIL}
          </Button>
        </div>
      </div>

      <h2>Helpful links</h2>
      <ul>
        <li>
          <Link to={LEGAL_ROUTES.accountDeletion}>Account deletion instructions</Link>
        </li>
        <li>
          <a href="/#faq">FAQ</a> (landing)
        </li>
      </ul>
    </LegalPageLayout>
  )
}
