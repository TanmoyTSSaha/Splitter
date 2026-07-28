import type { ReactNode } from 'react'
import styles from './LegalPageLayout.module.css'

type Props = {
  children: ReactNode
}

export function LegalPageLayout({ children }: Props) {
  return (
    <div className={`container ${styles.wrap}`}>
      <article className={`prose ${styles.article}`}>{children}</article>
    </div>
  )
}
