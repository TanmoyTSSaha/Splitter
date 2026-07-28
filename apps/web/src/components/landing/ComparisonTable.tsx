import { useRef } from 'react'
import { useComparisonMotion } from '../../hooks/motion/useLandingScrollMotion'
import styles from './ComparisonTable.module.css'

type Cell = 'yes' | 'no' | 'partial' | 'varies'

const columns = ['Splitr', 'Splitwise', 'BillSplit', 'BillSplitzer'] as const

const rows: { topic: string; values: Cell[] }[] = [
  { topic: 'UPI settle-up', values: ['yes', 'varies', 'yes', 'yes'] },
  { topic: 'Personal finance home', values: ['yes', 'partial', 'no', 'no'] },
  { topic: 'P2P lending', values: ['yes', 'no', 'no', 'no'] },
  { topic: 'Financial goals', values: ['yes', 'no', 'no', 'no'] },
  { topic: 'Receipt OCR (Pro)', values: ['yes', 'no', 'no', 'no'] },
  { topic: 'Offline group reads', values: ['partial', 'no', 'no', 'no'] },
]

function CellMark({ value }: { value: Cell }) {
  if (value === 'yes') {
    return (
      <span className={`${styles.yes} comparison-yes`} aria-label="Yes">
        ✓
      </span>
    )
  }
  if (value === 'partial') return <span className={styles.partial} aria-label="Partial">~</span>
  if (value === 'varies') return <span className={styles.muted}>Varies</span>
  return <span className={styles.muted} aria-label="No">—</span>
}

export function ComparisonTable() {
  const sectionRef = useRef<HTMLElement>(null)
  useComparisonMotion(sectionRef)

  return (
    <section ref={sectionRef} className={styles.section} id="compare" aria-labelledby="compare-heading">
      <div className="container">
        <h2 id="compare-heading" className={styles.heading}>
          How Splitr compares
        </h2>
        <p className={styles.note}>Factual comparison only. Features verified against shipped Splitr capabilities.</p>

        <div className={styles.tableWrap} data-motion-table>
          <div className={styles.scanLine} data-motion-scan aria-hidden="true" />
          <table className={styles.table}>
            <thead>
              <tr>
                <th scope="col">Feature</th>
                {columns.map((col, i) => (
                  <th key={col} scope="col" className={i === 0 ? styles.splitrCol : undefined}>
                    {col}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {rows.map((row) => (
                <tr key={row.topic}>
                  <th scope="row">{row.topic}</th>
                  {row.values.map((val, i) => (
                    <td key={columns[i]} className={i === 0 ? styles.splitrCol : undefined}>
                      <CellMark value={val} />
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className={styles.cards}>
          {columns.map((col, colIndex) => (
            <article
              key={col}
              className={`${styles.card} ${colIndex === 0 ? styles.cardSplitr : ''}`}
              data-motion-splitr-card={colIndex === 0 ? true : undefined}
            >
              <h3>{col}</h3>
              <ul>
                {rows.map((row) => (
                  <li key={row.topic}>
                    <span>{row.topic}</span>
                    <CellMark value={row.values[colIndex]} />
                  </li>
                ))}
              </ul>
            </article>
          ))}
        </div>
      </div>
    </section>
  )
}
