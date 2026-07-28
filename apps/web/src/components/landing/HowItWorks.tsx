import { useRef } from 'react'
import { useHowItWorksMotion } from '../../hooks/motion/useLandingScrollMotion'
import { StepIcon } from './StepIcon'
import styles from './HowItWorks.module.css'

const steps = [
  {
    id: 'group' as const,
    title: 'Create a group',
    body: 'Add friends or roommates and start tracking shared expenses together.',
  },
  {
    id: 'split' as const,
    title: 'Split expenses',
    body: 'Log bills, assign shares, and let Splitr calculate who owes whom.',
  },
  {
    id: 'settle' as const,
    title: 'Settle on UPI',
    body: 'Clear balances with UPI-friendly settle-up flows built for India.',
  },
]

export function HowItWorks() {
  const sectionRef = useRef<HTMLElement>(null)
  const stepsRef = useRef<HTMLOListElement>(null)
  const graphRef = useRef<SVGSVGElement>(null)

  useHowItWorksMotion(sectionRef, stepsRef, graphRef)

  return (
    <section ref={sectionRef} className={styles.section} id="how" aria-labelledby="how-heading">
      <div className="container">
        <h2 id="how-heading" className={styles.heading}>
          How it works
        </h2>
        <svg
          ref={graphRef}
          className={styles.graph}
          viewBox="0 0 400 48"
          aria-hidden="true"
        >
          <line
            data-motion-connector
            x1="58"
            y1="24"
            x2="190"
            y2="24"
            className={styles.connector}
          />
          <line
            data-motion-connector
            x1="210"
            y1="24"
            x2="342"
            y2="24"
            className={styles.connector}
          />
          {steps.map((step, i) => (
            <circle
              key={step.title}
              data-motion-node
              cx={48 + i * 152}
              cy="24"
              r="10"
              className={styles.node}
              data-active={i === 0 ? 'true' : 'false'}
            />
          ))}
        </svg>
        <ol ref={stepsRef} className={styles.steps}>
          {steps.map((step) => (
            <li key={step.title} className={styles.step} data-motion-step data-active="true">
              <StepIcon id={step.id} />
              <div>
                <h3>{step.title}</h3>
                <p>{step.body}</p>
              </div>
            </li>
          ))}
        </ol>
      </div>
    </section>
  )
}
