import { useCallback, useEffect, useState } from 'react'
import { useAuth } from '../context/AuthContext'
import { fetchFriendDetail, type FriendDetail } from '../lib/friendsData'

export function useFriendDetail(friendId: string | undefined) {
  const { user } = useAuth()
  const [detail, setDetail] = useState<FriendDetail | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const load = useCallback(async () => {
    if (!user || !friendId) {
      setDetail(null)
      setLoading(false)
      return
    }

    setLoading(true)
    setError(null)
    try {
      const data = await fetchFriendDetail(user.id, friendId)
      if (!data) {
        setError('Friend not found.')
        setDetail(null)
      } else {
        setDetail(data)
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not load friend.')
      setDetail(null)
    } finally {
      setLoading(false)
    }
  }, [user, friendId])

  useEffect(() => {
    void load()
  }, [load])

  return { detail, loading, error, reload: load }
}
