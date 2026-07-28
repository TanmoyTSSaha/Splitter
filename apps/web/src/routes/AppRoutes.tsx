import { Outlet } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { LoginPage } from '../pages/LoginPage'

export function AppGate() {
  const { user, loading, configured } = useAuth()

  if (!configured) {
    return (
      <div className="container" style={{ padding: '96px 0' }}>
        <h1>Splitr web app</h1>
        <p style={{ color: 'var(--color-text-muted)' }}>
          Set <code>VITE_SUPABASE_URL</code> and <code>VITE_SUPABASE_ANON_KEY</code> to enable sign
          in.
        </p>
      </div>
    )
  }

  if (loading) {
    return (
      <div className="container" style={{ padding: '96px 0', color: 'var(--color-text-muted)' }}>
        Loading…
      </div>
    )
  }

  if (!user) {
    return <LoginPage />
  }

  return <Outlet />
}
