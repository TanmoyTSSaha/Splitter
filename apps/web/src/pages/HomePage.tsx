import { ComparisonTable } from '../components/landing/ComparisonTable'
import { FaqSection } from '../components/landing/FaqSection'
import { FinalCta } from '../components/landing/FinalCta'
import { PhoneTourSection } from '../components/landing/tour/PhoneTourSection'
import { PricingSection } from '../components/landing/PricingSection'
import { TrustStrip } from '../components/landing/TrustStrip'
import { usePageMeta } from '../hooks/usePageMeta'
import { useSectionView } from '../hooks/useSectionView'

export function HomePage() {
  usePageMeta(
    'Splitr — Split bills, track spending, settle on UPI',
    'Split bills, track spending, and settle up with UPI. Splitr for groups and personal finance in India.',
    '/',
  )

  useSectionView('hero', 'hero')
  useSectionView('compare', 'comparison')
  useSectionView('pricing', 'pricing')
  useSectionView('trust', 'trust')
  useSectionView('faq', 'faq')
  useSectionView('download', 'download')

  return (
    <>
      <PhoneTourSection />

      <ComparisonTable />
      <PricingSection />
      <TrustStrip />
      <FaqSection />
      <FinalCta />
    </>
  )
}
