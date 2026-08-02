import { useState } from 'react'
import { AuthLayout } from '../components/auth/AuthLayout'
import { LoginForm } from '../components/auth/LoginForm'
import { RegisterForm } from '../components/auth/RegisterForm'
import styles from '../components/auth/AuthForm.module.css'
import { usePageMeta } from '../hooks/usePageMeta'

type Mode = 'signin' | 'signup'

export function LoginPage() {
  const [mode, setMode] = useState<Mode>('signin')

  usePageMeta(
    mode === 'signin' ? 'Sign in' : 'Create account',
    'Sign in to Splitr on the web to view your balances read-only.',
    '/app',
    { noIndex: true },
  )

  return (
    <AuthLayout title={mode === 'signin' ? 'Sign in to Splitr' : 'Create your account'}>
      <div className={styles.tabs} role="tablist" aria-label="Authentication mode">
        <button
          type="button"
          role="tab"
          aria-selected={mode === 'signin'}
          className={mode === 'signin' ? `${styles.tab} ${styles.tabActive}` : styles.tab}
          onClick={() => setMode('signin')}
        >
          Sign in
        </button>
        <button
          type="button"
          role="tab"
          aria-selected={mode === 'signup'}
          className={mode === 'signup' ? `${styles.tab} ${styles.tabActive}` : styles.tab}
          onClick={() => setMode('signup')}
        >
          Sign up
        </button>
      </div>
      {mode === 'signin' ? <LoginForm /> : <RegisterForm />}
    </AuthLayout>
  )
}
