import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { authCallbackUrl, supabase } from '../../lib/supabase'
import { Button } from '../Button'
import { OAuthButton } from './OAuthButton'
import styles from './AuthForm.module.css'

export function RegisterForm() {
  const navigate = useNavigate()
  const [displayName, setDisplayName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [verifyNotice, setVerifyNotice] = useState(false)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    if (!supabase) return
    setLoading(true)
    setError(null)
    setVerifyNotice(false)

    const trimmedEmail = email.trim()
    const trimmedName = displayName.trim()
    const userName = trimmedName.toLowerCase().replace(/\s+/g, '_').slice(0, 32)

    const { data, error: signUpError } = await supabase.auth.signUp({
      email: trimmedEmail,
      password,
      options: {
        emailRedirectTo: authCallbackUrl(),
        data: {
          user_name: userName || trimmedEmail.split('@')[0],
          first_name: trimmedName.split(' ')[0] ?? trimmedName,
          last_name: trimmedName.split(' ').slice(1).join(' ') || trimmedName,
        },
      },
    })

    setLoading(false)
    if (signUpError) {
      setError(signUpError.message)
      return
    }

    if (data.session) {
      navigate('/app', { replace: true })
      return
    }

    setVerifyNotice(true)
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
      {verifyNotice ? (
        <div className={styles.success} role="status">
          Check your email to verify your account, then sign in.
        </div>
      ) : null}

      <div className={styles.field}>
        <label className={styles.label} htmlFor="register-name">
          Display name
        </label>
        <input
          id="register-name"
          className={styles.input}
          type="text"
          autoComplete="name"
          value={displayName}
          onChange={(e) => setDisplayName(e.target.value)}
          disabled={loading}
          required
        />
      </div>

      <div className={styles.field}>
        <label className={styles.label} htmlFor="register-email">
          Email
        </label>
        <input
          id="register-email"
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
        <label className={styles.label} htmlFor="register-password">
          Password
        </label>
        <input
          id="register-password"
          className={styles.input}
          type="password"
          autoComplete="new-password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          disabled={loading}
          minLength={8}
          required
        />
      </div>

      <Button type="submit" disabled={loading || !supabase}>
        {loading ? 'Creating account…' : 'Create account'}
      </Button>
    </form>
  )
}
