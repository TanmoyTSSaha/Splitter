import styles from './ComparisonTable.module.css'

type Cell = 'yes' | 'no' | 'partial' | 'varies'

type Column = {
  id: 'splitr' | 'splitwise' | 'splitkaro'
  name: string
  mark: string
  highlight?: boolean
}

type Row = {
  topic: string
  values: [Cell, Cell, Cell]
  splitrNote?: string
}

const columns: Column[] = [
  { id: 'splitr', name: 'Splitr', mark: 'S', highlight: true },
  { id: 'splitwise', name: 'Splitwise', mark: 'W' },
  { id: 'splitkaro', name: 'Splitkaro', mark: 'K' },
]

const rows: Row[] = [
  {
    topic: 'UPI settle-up',
    values: ['yes', 'varies', 'yes'],
    splitrNote: 'UPI-friendly settle',
  },
  { topic: 'Personal finance home', values: ['yes', 'partial', 'yes'] },
  { topic: 'P2P lending', values: ['yes', 'no', 'no'] },
  { topic: 'Financial goals', values: ['yes', 'no', 'no'] },
  { topic: 'Free core (no daily caps)', values: ['yes', 'no', 'yes'] },
  {
    topic: 'Receipt OCR (Pro)',
    values: ['yes', 'yes', 'no'],
    splitrNote: 'Pro',
  },
]

function CellMark({ value }: { value: Cell }) {
  if (value === 'yes') {
    return (
      <span className={styles.yes} aria-label="Yes">
        ✓
      </span>
    )
  }
  if (value === 'partial') return <span className={styles.partial} aria-label="Partial">~</span>
  if (value === 'varies') return <span className={styles.muted}>Varies</span>
  return <span className={styles.muted} aria-label="No">—</span>
}

function ColumnMark({ mark, highlight }: { mark: string; highlight?: boolean }) {
  return (
    <span
      className={`${styles.colMark} ${highlight ? styles.colMarkSplitr : ''}`}
      aria-hidden="true"
    >
      {mark}
    </span>
  )
}

export function ComparisonTable() {
  return (
    <section className={styles.section} id="compare" aria-labelledby="compare-heading">
      <div className="container">
        <h2 id="compare-heading" className={styles.heading}>
          How Splitr compares
        </h2>
        <p className={styles.note}>
          Factual comparison. Features checked against shipped Splitr and public competitor info.
        </p>

        <div className={styles.tableWrap}>
          <div className={styles.cardShell}>
            <table className={styles.table}>
              <thead>
                <tr>
                  <th scope="col">Feature</th>
                  {columns.map((col) => (
                    <th
                      key={col.id}
                      scope="col"
                      className={col.highlight ? styles.splitrCol : undefined}
                    >
                      <span className={styles.colHead}>
                        <ColumnMark mark={col.mark} highlight={col.highlight} />
                        <span>{col.name}</span>
                      </span>
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {rows.map((row) => (
                  <tr key={row.topic}>
                    <th scope="row">{row.topic}</th>
                    {row.values.map((val, i) => (
                      <td
                        key={columns[i].id}
                        className={columns[i].highlight ? styles.splitrCol : undefined}
                      >
                        <div className={styles.cellStack}>
                          <CellMark value={val} />
                          {columns[i].highlight && row.splitrNote ? (
                            <span className={styles.splitrNote}>{row.splitrNote}</span>
                          ) : null}
                        </div>
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </section>
  )
}
