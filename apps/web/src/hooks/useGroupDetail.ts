import { useCallback, useEffect, useState } from 'react'
import { useAuth } from '../context/AuthContext'
import { fetchGroupDetail, type GroupDetail } from '../lib/groupsData'

export function useGroupDetail(groupId: string | undefined) {
  const { user } = useAuth()
  const [detail, setDetail] = useState<GroupDetail | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const load = useCallback(async () => {
    if (!user || !groupId) {
      setDetail(null)
      setLoading(false)
      return
    }

    setLoading(true)
    setError(null)
    try {
      const data = await fetchGroupDetail(user.id, groupId)
      if (!data) {
        setError('Group not found.')
        setDetail(null)
      } else {
        setDetail(data)
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not load group.')
      setDetail(null)
    } finally {
      setLoading(false)
    }
  }, [user, groupId])

  useEffect(() => {
    void load()
  }, [load])

  return { detail, loading, error, reload: load }
}
