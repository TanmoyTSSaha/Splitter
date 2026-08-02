import { Link } from 'react-router-dom'
import { LegalPageLayout } from '../components/LegalPageLayout'
import {
  LEGAL_ROUTES,
  OPERATOR_LINE,
  PRIVACY_LAST_UPDATED,
  SUPPORT_EMAIL,
} from '../constants/site'
import { usePageMeta } from '../hooks/usePageMeta'

export function PrivacyPage() {
  usePageMeta(
    'Privacy Policy',
    'How Splitr collects, uses, and protects your data.',
    LEGAL_ROUTES.privacy,
  )

  return (
    <LegalPageLayout>
      <h1>Privacy Policy</h1>
      <p className="muted">Last updated: {PRIVACY_LAST_UPDATED}</p>
      <p>{OPERATOR_LINE}</p>

      <h2>1. Who we are</h2>
      <p>
        Splitr is a personal finance and expense-splitting app. {OPERATOR_LINE} For privacy
        questions, contact us at{' '}
        <a href={`mailto:${SUPPORT_EMAIL}`}>{SUPPORT_EMAIL}</a>.
      </p>

      <h2>2. Data we collect</h2>
      <ul>
        <li>
          <strong>Account data:</strong> email address, display name, and Google OAuth profile
          information when you sign in.
        </li>
        <li>
          <strong>Financial data:</strong> personal transactions, group expenses, balances,
          settlements, loans, and financial goals you create in the app.
        </li>
        <li>
          <strong>Device permissions:</strong> contacts (friend discovery, with your permission),
          camera (receipt OCR), and biometrics (app lock, on-device only).
        </li>
        <li>
          <strong>Usage data:</strong> app interactions, crash reports, and website analytics when
          you consent to cookies.
        </li>
      </ul>

      <h2>3. How we use data</h2>
      <p>
        We use your data to provide and improve Splitr: syncing your expenses, calculating balances,
        sending notifications, securing your account, and—when enabled—powering AI-assisted insights
        and goal features via Google Gemini. We do not sell your personal data.
      </p>

      <h2>4. Third-party services</h2>
      <ul>
        <li>
          <strong>Supabase</strong> — authentication, database, and hosting.
        </li>
        <li>
          <strong>Sentry</strong> — error monitoring to improve stability.
        </li>
        <li>
          <strong>Firebase Cloud Messaging</strong> — push notifications.
        </li>
        <li>
          <strong>Google Sign-In</strong> — optional sign-in provider.
        </li>
        <li>
          <strong>Google Play Billing</strong> — Splitr Pro subscriptions purchased in the Android
          app.
        </li>
        <li>
          <strong>Razorpay</strong> — in-app donations and settle-up payments (not Pro
          subscriptions).
        </li>
        <li>
          <strong>Google Analytics 4</strong> — website usage analytics (only after cookie consent).
        </li>
        <li>
          <strong>Frankfurter</strong> — public exchange-rate data for currency conversion.
        </li>
        <li>
          <strong>Google ML Kit</strong> — on-device receipt text recognition where supported.
        </li>
      </ul>

      <h2>5. Data retention and deletion</h2>
      <p>
        You can delete your account from the app (Profile → Delete account) or by emailing{' '}
        <a href={`mailto:${SUPPORT_EMAIL}`}>{SUPPORT_EMAIL}</a>. See our{' '}
        <Link to={LEGAL_ROUTES.accountDeletion}>account deletion instructions</Link> for details on
        what is removed and retention exceptions.
      </p>

      <h2>6. Security</h2>
      <p>
        We use encryption in transit (HTTPS/TLS), row-level security in our database, and
        industry-standard access controls. No method of transmission or storage is 100% secure.
      </p>

      <h2>7. Children&apos;s privacy</h2>
      <p>
        Splitr is not directed at children under 13. We do not knowingly collect data from children
        under 13.
      </p>

      <h2>8. International users</h2>
      <p>
        Splitr is India-first. Your data may be processed in regions where our service providers
        operate, including outside India, subject to applicable safeguards.
      </p>

      <h2>9. Changes to this policy</h2>
      <p>
        We may update this policy from time to time. The &quot;Last updated&quot; date at the top
        reflects the latest revision. Continued use after changes constitutes acceptance of the
        updated policy.
      </p>

      <h2>10. Contact</h2>
      <p>
        Email <a href={`mailto:${SUPPORT_EMAIL}`}>{SUPPORT_EMAIL}</a> for privacy-related requests.
      </p>
    </LegalPageLayout>
  )
}
