import type { ReactNode } from 'react'
import { AppBar } from './AppBar'
import { BottomNav } from './BottomNav'
import { StatusBar } from './StatusBar'
import styles from './Screen.module.css'

type ScreenProps = {
  activeIndex: number
  children: ReactNode
  /** Profile has no AppBar — its content starts under the status bar. */
  showAppBar?: boolean
}

export function Screen({ activeIndex, children, showAppBar = true }: ScreenProps) {
  return (
    <div className={styles.scaffold}>
      <StatusBar />
      {showAppBar ? <AppBar /> : null}
      <div className={styles.content}>{children}</div>
      <BottomNav activeIndex={activeIndex} />
    </div>
  )
}
