import { useEffect, useRef, useState } from 'react'
import { Link } from 'react-router-dom'
import { trackInstallClick, trackSignInClick } from '../lib/analytics'
import { useFocusTrap } from '../hooks/useFocusTrap'
import { Logo } from './Logo'
import { PlayStoreBadge } from './PlayStoreBadge'
import styles from './Nav.module.css'

const anchorLinks = [
  { href: '/#features', label: 'Features' },
  { href: '/#pricing', label: 'Pricing' },
  { href: '/#faq', label: 'FAQ' },
]

export function Nav() {
  const [scrolled, setScrolled] = useState(false)
  const [drawerOpen, setDrawerOpen] = useState(false)
  const drawerRef = useRef<HTMLElement>(null)
  const menuBtnRef = useRef<HTMLButtonElement>(null)

  useFocusTrap(drawerRef, drawerOpen)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 48)
    onScroll()
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  useEffect(() => {
    document.body.style.overflow = drawerOpen ? 'hidden' : ''
    return () => {
      document.body.style.overflow = ''
    }
  }, [drawerOpen])

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setDrawerOpen(false)
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [])

  const closeDrawer = () => {
    setDrawerOpen(false)
    menuBtnRef.current?.focus()
  }

  return (
    <>
      <header
        className={`site-nav ${styles.nav} ${scrolled ? styles.navScrolled : ''}`}
      >
        <div className={`container ${styles.inner}`}>
          <Logo />
          <nav className={styles.desktopLinks} aria-label="Primary">
            {anchorLinks.map((item) => (
              <a key={item.href} href={item.href} className={styles.navLink}>
                {item.label}
              </a>
            ))}
          </nav>
          <div className={styles.actions}>
            <Link to="/app" className={styles.signIn} onClick={() => trackSignInClick('nav')}>
              Sign in
            </Link>
            <PlayStoreBadge
              size="compact"
              className={styles.navBadge}
              onClick={() => trackInstallClick('nav')}
            />
            <button
              type="button"
              ref={menuBtnRef}
              className={styles.menuBtn}
              aria-label="Open menu"
              aria-expanded={drawerOpen}
              aria-controls="nav-drawer"
              onClick={() => setDrawerOpen(true)}
            >
              <span />
              <span />
              <span />
            </button>
          </div>
        </div>
      </header>

      {drawerOpen ? (
        <button
          type="button"
          className={`nav-drawer-overlay ${styles.overlay}`}
          aria-label="Close menu"
          onClick={closeDrawer}
        />
      ) : null}

      <aside
        ref={drawerRef}
        id="nav-drawer"
        className={`${styles.drawer} ${drawerOpen ? styles.drawerOpen : ''}`}
        aria-hidden={!drawerOpen}
        aria-modal={drawerOpen}
        role="dialog"
        aria-label="Navigation menu"
        {...(!drawerOpen ? { inert: true as const } : {})}
      >
        <div className={styles.drawerHeader}>
          <Logo />
          <button type="button" className={styles.closeBtn} onClick={closeDrawer}>
            Close
          </button>
        </div>
        <nav className={styles.drawerNav} aria-label="Mobile">
          {anchorLinks.map((item) => (
            <a key={item.href} href={item.href} className={styles.drawerLink} onClick={closeDrawer}>
              {item.label}
            </a>
          ))}
          <Link
            to="/app"
            className={styles.drawerLink}
            onClick={() => {
              trackSignInClick('nav_drawer')
              closeDrawer()
            }}
          >
            Sign in
          </Link>
          <PlayStoreBadge
            className={styles.drawerBadge}
            onClick={() => {
              trackInstallClick('nav_drawer')
              closeDrawer()
            }}
          />
        </nav>
      </aside>
    </>
  )
}
