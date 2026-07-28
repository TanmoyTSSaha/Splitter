import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { authCallbackUrl, supabase } from '../../lib/supabase'
import { Button } from '../Button'
import { OAuthButton } from './OAuthButton'
import styles from './AuthForm.module.css'

export function LoginForm() {
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [resetSent, setResetSent] = useState(false)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    if (!supabase) return
    setLoading(true)
    setError(null)
    setResetSent(false)

    const { error: signInError } = await supabase.auth.signInWithPassword({
      email: email.trim(),
      password,
    })

    setLoading(false)
    if (signInError) {
      setError(signInError.message)
      return
    }
    navigate('/app', { replace: true })
  }

  async function handleForgotPassword() {
    if (!supabase) return
    const trimmed = email.trim()
    if (!trimmed) {
      setError('Enter your email above, then tap forgot password.')
      return
    }
    setLoading(true)
    setError(null)
    const { error: resetError } = await supabase.auth.resetPasswordForEmail(trimmed, {
      redirectTo: authCallbackUrl(),
    })
    setLoading(false)
    if (resetError) {
      setError(resetError.message)
      return
    }
    setResetSent(true)
  }

  return (
    <form className={styles.form} onSubmit={(e) => void handleSubmit(e)}>
      <OAuthButton disabled={loading} />
      <div className={styles.divider}>or</div>

      {error ? (
        <div className={styles.error} role="alert">
          {error}
        </div>
      ) : null}
      {resetSent ? (
        <div className={styles.success} role="status">
          Password reset email sent. Check your inbox.
        </div>
      ) : null}

      <div className={styles.field}>
        <label className={styles.label} htmlFor="login-email">
          Email
        </label>
        <input
          id="login-email"
          className={styles.input}
          type="email"
          autoComplete="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          disabled={loading}
          required
        />
      </div>

      <div className={styles.field}>
        <label className={styles.label} htmlFor="login-password">
          Password
        </label>
        <input
          id="login-password"
          className={styles.input}
          type="password"
          autoComplete="current-password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          disabled={loading}
          required
        />
      </div>

      <Button type="submit" disabled={loading || !supabase}>
        {loading ? 'Signing in…' : 'Sign in'}
      </Button>

      <div className={styles.linkRow}>
        <button
          type="button"
          className={styles.linkButton}
          onClick={() => void handleForgotPassword()}
          disabled={loading}
        >
          Forgot password?
        </button>
      </div>
    </form>
  )
}
