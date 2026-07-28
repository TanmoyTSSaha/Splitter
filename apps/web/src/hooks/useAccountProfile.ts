import { useCallback, useEffect, useState } from 'react'
import { useAuth } from '../context/AuthContext'
import { fetchAccountProfile, type AccountProfile } from '../lib/accountData'

export function useAccountProfile() {
  const { user } = useAuth()
  const [profile, setProfile] = useState<AccountProfile | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const load = useCallback(async () => {
    if (!user) {
      setProfile(null)
      setLoading(false)
      return
    }

    setLoading(true)
    setError(null)
    try {
      setProfile(await fetchAccountProfile(user.id, user.email))
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not load account.')
      setProfile({
        displayName: user.email?.split('@')[0] ?? 'Splitr user',
        email: user.email ?? '',
        isPremium: false,
      })
    } finally {
      setLoading(false)
    }
  }, [user])

  useEffect(() => {
    void load()
  }, [load])

  return { profile, loading, error, reload: load }
}
