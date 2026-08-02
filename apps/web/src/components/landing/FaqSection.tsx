import { useState } from 'react'
import { Link } from 'react-router-dom'
import { LEGAL_ROUTES } from '../../constants/site'
import styles from './FaqSection.module.css'

const faqs = [
  {
    q: 'Is Splitr free?',
    a: 'Yes. Core expense splitting, groups, and personal tracking are free. Splitr Pro adds advanced tools like receipt OCR.',
  },
  {
    q: 'What is Splitr Pro?',
    a: 'Pro is a subscription (₹89/month or ₹799/year) for power features. You subscribe inside the Android app via Google Play.',
  },
  {
    q: 'Is my data safe?',
    a: 'We use encryption in transit, row-level security, and industry-standard practices. Read our Privacy Policy for details.',
    link: LEGAL_ROUTES.privacy,
    linkLabel: 'Privacy Policy',
  },
  {
    q: 'How do I delete my account?',
    a: 'Use Profile → Delete account in the app, or follow our account deletion instructions online.',
    link: LEGAL_ROUTES.accountDeletion,
    linkLabel: 'Account deletion',
  },
  {
    q: 'Can I use Splitr on the web?',
    a: 'You can sign in on the web to view balances (read-only v1). To add expenses or settle up, use the Android app.',
  },
  {
    q: 'Does Splitr support UPI?',
    a: 'Yes. Settle-up flows are built with India-friendly UPI deep links so you can clear balances quickly.',
  },
]

export function FaqSection() {
  const [open, setOpen] = useState<number | null>(0)

  return (
    <section className={styles.section} id="faq" aria-labelledby="faq-heading">
      <div className="container">
        <h2 id="faq-heading" className={styles.heading}>
          FAQ
        </h2>
        <div className={styles.list}>
          {faqs.map((item, i) => {
            const expanded = open === i
            const answerId = `faq-answer-${i}`
            return (
              <div key={item.q} className={styles.item}>
                <button
                  type="button"
                  className={styles.question}
                  aria-expanded={expanded}
                  aria-controls={answerId}
                  onClick={() => setOpen(expanded ? null : i)}
                >
                  {item.q}
                  <span className={styles.chevron} aria-hidden="true">
                    +
                  </span>
                </button>
                <div
                  id={answerId}
                  className={styles.answerPanel}
                  data-open={expanded}
                  aria-hidden={!expanded}
                  {...(!expanded ? { inert: true as const } : {})}
                >
                  <div className={styles.answerInner}>
                    <div className={styles.answer}>
                      <p>
                        {item.a}
                        {item.link ? (
                          <>
                            {' '}
                            <Link to={item.link}>{item.linkLabel}</Link>
                          </>
                        ) : null}
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            )
          })}
        </div>
      </div>
    </section>
  )
}
