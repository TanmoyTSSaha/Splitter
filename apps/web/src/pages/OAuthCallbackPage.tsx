import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { usePageMeta } from '../hooks/usePageMeta'
import { supabase } from '../lib/supabase'
import styles from './OAuthCallbackPage.module.css'

export function OAuthCallbackPage() {
  const navigate = useNavigate()
  const [message, setMessage] = useState('Completing sign in…')

  usePageMeta('Signing in', 'Completing Splitr sign in.', '/app/oauth/callback', { noIndex: true })
  useEffect(() => {
    if (!supabase) {
      setMessage('Supabase is not configured.')
      return
    }

    let mounted = true

    async function finish() {
      const params = new URLSearchParams(window.location.search)
      const code = params.get('code')

      if (code) {
        const { error } = await supabase!.auth.exchangeCodeForSession(code)
        if (!mounted) return
        if (error) {
          setMessage(error.message)
          return
        }
      } else {
        const { error } = await supabase!.auth.getSession()
        if (!mounted) return
        if (error) {
          setMessage(error.message)
          return
        }
      }

      navigate('/app', { replace: true })
    }

    void finish()

    return () => {
      mounted = false
    }
  }, [navigate])

  return (
    <div className={`container ${styles.page}`}>
      <p className={styles.message}>{message}</p>
    </div>
  )}
