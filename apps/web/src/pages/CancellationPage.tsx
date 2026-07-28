import { Link } from 'react-router-dom'
import { LegalPageLayout } from '../components/LegalPageLayout'
import { LEGAL_ROUTES, OPERATOR_LINE, PRIVACY_LAST_UPDATED, SUPPORT_EMAIL } from '../constants/site'
import { usePageMeta } from '../hooks/usePageMeta'

export function CancellationPage() {
  usePageMeta(
    'Cancellation Policy',
    'How to cancel Splitr Pro and your account.',
    LEGAL_ROUTES.cancellation,
  )

  return (
    <LegalPageLayout>
      <h1>Cancellation Policy</h1>
      <p className="muted">Last updated: {PRIVACY_LAST_UPDATED}</p>
      <p>{OPERATOR_LINE}</p>

      <h2>Cancel Splitr Pro</h2>
      <p>
        Open Google Play → Payments &amp; subscriptions → Subscriptions → Splitr Pro → Cancel.
        Cancellation takes effect at the end of the current billing period unless Play policy states
        otherwise. You keep Pro access until that date.
      </p>

      <h2>Refunds after cancellation</h2>
      <p>
        Cancelling does not automatically refund unused time. See our{' '}
        <Link to={LEGAL_ROUTES.refund}>Refund Policy</Link>.
      </p>

      <h2>Cancel subscription vs delete account</h2>
      <p>
        Cancelling Pro stops future subscription charges but keeps your Splitr account. Deleting
        your account removes your data per our{' '}
        <Link to={LEGAL_ROUTES.accountDeletion}>account deletion</Link> instructions.
      </p>

      <h2>Need help?</h2>
      <p>
        Email <a href={`mailto:${SUPPORT_EMAIL}`}>{SUPPORT_EMAIL}</a> if you cannot cancel through
        Play Store.
      </p>
    </LegalPageLayout>
  )
}
