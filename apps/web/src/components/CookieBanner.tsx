import { useEffect, useState } from 'react'

import { Link } from 'react-router-dom'

import { LEGAL_ROUTES } from '../constants/site'

import { getStoredConsent, storeConsent } from '../lib/analytics'

import { Button } from './Button'

import styles from './CookieBanner.module.css'



const SHOW_DELAY_MS = 1000



export function CookieBanner() {

  const [visible, setVisible] = useState(false)

  const [exiting, setExiting] = useState(false)



  useEffect(() => {

    const consent = getStoredConsent()

    if (consent) {

      if (consent === 'accepted') {

        storeConsent('accepted')

      }

      return

    }



    const timer = window.setTimeout(() => setVisible(true), SHOW_DELAY_MS)

    return () => window.clearTimeout(timer)

  }, [])



  if (!visible) return null



  const dismiss = (value: 'accepted' | 'rejected') => {

    setExiting(true)

    window.setTimeout(() => {

      storeConsent(value)

      setVisible(false)

    }, 200)

  }



  return (

    <div

      className={`cookie-banner ${styles.banner} ${exiting ? styles.bannerExit : ''}`}

      role="dialog"

      aria-label="Cookie consent"

    >

      <div className={`container ${styles.inner}`}>

        <p className={styles.text}>

          We use cookies for analytics on this website. See our{' '}

          <Link to={LEGAL_ROUTES.privacy}>Privacy Policy</Link> for details.

        </p>

        <div className={styles.actions}>

          <Button variant="ghost" onClick={() => dismiss('rejected')}>

            Reject non-essential

          </Button>

          <Button onClick={() => dismiss('accepted')}>Accept</Button>

        </div>

      </div>

    </div>

  )

}

