import type { ReactNode } from 'react'
import { Logo } from '../Logo'
import styles from './AuthLayout.module.css'

type Props = {
  title: string
  children: ReactNode
}

export function AuthLayout({ title, children }: Props) {
  return (
    <div className={styles.page}>
      <div className={styles.logoWrap}>
        <Logo />
      </div>
      <div className={styles.card}>
        <h1 className={styles.title}>{title}</h1>
        {children}
      </div>
    </div>
  )
}
