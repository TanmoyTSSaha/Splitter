import { useCallback, useEffect, useState } from 'react'
import { useAuth } from '../context/AuthContext'
import { fetchFriends, type FriendSummary } from '../lib/friendsData'

export function useFriendsList() {
  const { user } = useAuth()
  const [friends, setFriends] = useState<FriendSummary[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const load = useCallback(async () => {
    if (!user) {
      setFriends([])
      setLoading(false)
      return
    }

    setLoading(true)
    setError(null)
    try {
      setFriends(await fetchFriends(user.id))
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not load friends.')
      setFriends([])
    } finally {
      setLoading(false)
    }
  }, [user])

  useEffect(() => {
    void load()
  }, [load])

  return { friends, loading, error, reload: load }
}
