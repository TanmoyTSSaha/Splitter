import { Link } from 'react-router-dom'
import { LegalPageLayout } from '../components/LegalPageLayout'
import { LEGAL_ROUTES, OPERATOR_LINE, PRIVACY_LAST_UPDATED, SUPPORT_EMAIL } from '../constants/site'
import { usePageMeta } from '../hooks/usePageMeta'

export function TermsPage() {
  usePageMeta('Terms of Service', 'Rules for using Splitr.', LEGAL_ROUTES.terms)

  return (
    <LegalPageLayout>
      <h1>Terms of Service</h1>
      <p className="muted">Last updated: {PRIVACY_LAST_UPDATED}</p>
      <p>{OPERATOR_LINE}</p>

      <h2>1. Acceptance</h2>
      <p>
        By downloading, accessing, or using Splitr, you agree to these Terms. If you do not agree,
        do not use the service.
      </p>

      <h2>2. Service description</h2>
      <p>
        Splitr provides expense splitting with groups and friends, personal finance tracking,
        informal lending tools, and financial goals. Features may change as the product evolves.
      </p>

      <h2>3. Your account</h2>
      <p>
        You are responsible for your account credentials and for activity under your account. Provide
        accurate information and notify us of unauthorized access at{' '}
        <a href={`mailto:${SUPPORT_EMAIL}`}>{SUPPORT_EMAIL}</a>.
      </p>

      <h2>4. Acceptable use</h2>
      <p>
        Do not misuse Splitr: no fraud, harassment, illegal activity, attempts to breach security,
        or interference with other users&apos; data.
      </p>

      <h2>5. Splitr Pro</h2>
      <p>
        Splitr Pro is a subscription (₹89/month or ₹799/year, subject to change) billed through
        Google Play. Subscriptions auto-renew unless cancelled in Play Store settings. Pro checkout
        occurs in the app, not on this website.
      </p>

      <h2>6. Payments</h2>
      <p>
        Splitr Pro is billed exclusively through Google Play Billing. Donations and settle-up
        payments in the app may be processed by Razorpay. You agree to the applicable payment
        provider&apos;s terms for each flow.
      </p>

      <h2>7. Intellectual property</h2>
      <p>
        Splitr, its branding, and software are owned by the operator. You retain ownership of data
        you submit; you grant us a licence to host and process it to provide the service.
      </p>

      <h2>8. Limitation of liability</h2>
      <p>
        Splitr is provided &quot;as is&quot; to the maximum extent permitted by law. We are not
        liable for indirect or consequential damages. Our total liability is limited to fees you paid
        us in the twelve months before the claim.
      </p>

      <h2>9. Indemnity</h2>
      <p>You agree to indemnify us against claims arising from your misuse of Splitr or violation of these Terms.</p>

      <h2>10. Termination</h2>
      <p>
        You may stop using Splitr anytime and delete your account. We may suspend or terminate access
        for violations. See <Link to={LEGAL_ROUTES.accountDeletion}>account deletion</Link>.
      </p>

      <h2>11. Governing law</h2>
      <p>These Terms are governed by the laws of India. Courts in India have exclusive jurisdiction.</p>

      <h2>12. Changes</h2>
      <p>We may update these Terms. The last updated date reflects the current version.</p>

      <h2>13. Contact</h2>
      <p>
        <a href={`mailto:${SUPPORT_EMAIL}`}>{SUPPORT_EMAIL}</a>
      </p>
    </LegalPageLayout>
  )
}
