import { Link } from 'react-router-dom'
import { LegalPageLayout } from '../components/LegalPageLayout'
import { LEGAL_ROUTES, OPERATOR_LINE, PRIVACY_LAST_UPDATED, SUPPORT_EMAIL } from '../constants/site'
import { usePageMeta } from '../hooks/usePageMeta'

export function AccountDeletionPage() {
  usePageMeta(
    'Account Deletion',
    'How to delete your Splitr account and data.',
    LEGAL_ROUTES.accountDeletion,
  )

  return (
    <LegalPageLayout>
      <h1>Account Deletion</h1>
      <p className="muted">Last updated: {PRIVACY_LAST_UPDATED}</p>
      <p>{OPERATOR_LINE}</p>

      <h2>Delete in the app</h2>
      <ol>
        <li>Open Splitr on your device.</li>
        <li>Go to Profile → Settings.</li>
        <li>Select Delete account and confirm.</li>
      </ol>

      <h2>Delete by email</h2>
      <p>
        If you cannot access the app, email{' '}
        <a href={`mailto:${SUPPORT_EMAIL}`}>{SUPPORT_EMAIL}</a> from your registered address with
        the subject &quot;Account deletion request&quot;. We may ask you to verify ownership.
      </p>

      <h2>What is deleted</h2>
      <p>
        Profile information, personal transactions, group memberships, and associated expense data
        tied to your account are removed or anonymized per our technical deletion process.
      </p>

      <h2>Retention exceptions</h2>
      <p>
        We may retain minimal records where required by law, fraud prevention, or backup cycles
        (typically up to 30 days before purging from active systems).
      </p>

      <h2>Timeline</h2>
      <p>Deletion requests are processed within 30 days. You will receive confirmation by email.</p>

      <h2>Privacy</h2>
      <p>
        See our <Link to={LEGAL_ROUTES.privacy}>Privacy Policy</Link> for full data practices.
      </p>
    </LegalPageLayout>
  )
}
