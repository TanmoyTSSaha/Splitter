import { NavLink, Outlet, useLocation } from 'react-router-dom'
import { Logo } from '../Logo'
import styles from './AppShell.module.css'

const NAV = [
  { to: '/app', label: 'Overview' },
  { to: '/app/groups', label: 'Groups' },
  { to: '/app/friends', label: 'Friends' },
  { to: '/app/account', label: 'Account' },
] as const

const TITLES: Record<string, string> = {
  '/app': 'Overview',
  '/app/groups': 'Groups',
  '/app/friends': 'Friends',
  '/app/account': 'Account',
}

function navClassName({ isActive }: { isActive: boolean }) {
  return isActive ? `${styles.navLink} ${styles.navLinkActive}` : styles.navLink
}

function tabClassName({ isActive }: { isActive: boolean }) {
  return isActive ? `${styles.tabLink} ${styles.tabLinkActive}` : styles.tabLink
}

export function AppShell() {
  const { pathname } = useLocation()
  const title =
    TITLES[pathname] ??
    (pathname.startsWith('/app/groups/') ? 'Group' : pathname.startsWith('/app/friends/') ? 'Friend' : 'Splitr')

  return (
    <div className={styles.shell}>
      <aside className={styles.sidebar}>
        <div className={styles.logo}>
          <Logo />
        </div>
        <nav className={styles.nav} aria-label="App">
          {NAV.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === '/app'}
              className={navClassName}
            >
              {item.label}
            </NavLink>
          ))}
        </nav>
      </aside>

      <div className={styles.main}>
        <header className={styles.topBar}>
          <h1 className={styles.topBarTitle}>{title}</h1>
          <Logo />
        </header>

        <main className={styles.content}>
          <Outlet />
        </main>

        <nav className={styles.bottomTabs} aria-label="App tabs">
          {NAV.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === '/app'}
              className={tabClassName}
            >
              <span>{item.label}</span>
            </NavLink>
          ))}
        </nav>
      </div>
    </div>
  )
}
