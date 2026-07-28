import { useEffect } from 'react'
import { Outlet, useLocation } from 'react-router-dom'
import { initSmoothScroll } from '../lib/motion/smoothScroll'
import { CookieBanner } from './CookieBanner'
import { Footer } from './Footer'
import { IntroOverlay } from './motion/IntroOverlay'
import { Nav } from './Nav'
import styles from './MarketingLayout.module.css'

export function MarketingLayout() {
  const location = useLocation()

  // Marketing pages only — the signed-in app shell keeps native scrolling.
  useEffect(() => initSmoothScroll(), [])

  return (
    <div className={styles.shell}>
      <IntroOverlay />
      <a href="#main-content" className="skip-link">
        Skip to content
      </a>
      <Nav />
      <main id="main-content" className={styles.main}>
        <div key={location.pathname} className={styles.pageTransition}>
          <Outlet />
        </div>
      </main>
      <Footer />
      <CookieBanner />
    </div>
  )
}
