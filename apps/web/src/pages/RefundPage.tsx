import { LegalPageLayout } from '../components/LegalPageLayout'
import { LEGAL_ROUTES, OPERATOR_LINE, PRIVACY_LAST_UPDATED, SUPPORT_EMAIL } from '../constants/site'
import { usePageMeta } from '../hooks/usePageMeta'

export function RefundPage() {
  usePageMeta('Refund Policy', 'Refunds for Splitr Pro and in-app payments.', LEGAL_ROUTES.refund)

  return (
    <LegalPageLayout>
      <h1>Refund Policy</h1>
      <p className="muted">Last updated: {PRIVACY_LAST_UPDATED}</p>
      <p>{OPERATOR_LINE}</p>

      <h2>Splitr Pro subscriptions</h2>
      <p>
        Splitr Pro is purchased through Google Play. Refunds follow Google Play&apos;s refund
        policies and timelines. To request a refund, use the Play Store order history or contact
        Google support.
      </p>

      <h2>Donations and settle-up (Razorpay)</h2>
      <p>
        Donations and settle-up charges processed by Razorpay are subject to Razorpay and applicable
        RBI guidelines. These are separate from Splitr Pro. Payment disputes may be raised through
        Razorpay or by emailing us.
      </p>

      <h2>How to request help</h2>
      <p>
        Email <a href={`mailto:${SUPPORT_EMAIL}`}>{SUPPORT_EMAIL}</a> with your account email,
        transaction date, and amount. We respond on a best-effort basis (India timezone).
      </p>

      <h2>Processing time</h2>
      <p>Approved refunds typically process within 5–10 business days, depending on your bank or Play Store.</p>

      <h2>Non-refundable cases</h2>
      <p>
        Partial subscription periods already used, chargebacks filed in bad faith, or violations of
        our Terms may not qualify for refund.
      </p>

      <h2>Consumer rights</h2>
      <p>Nothing in this policy limits your statutory rights under applicable Indian consumer law.</p>
    </LegalPageLayout>
  )
}
