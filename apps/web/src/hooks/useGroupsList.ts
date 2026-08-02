import { useCallback, useEffect, useState } from 'react'
import { useAuth } from '../context/AuthContext'
import { fetchUserGroups, type GroupSummary } from '../lib/groupsData'

export function useGroupsList() {
  const { user } = useAuth()
  const [groups, setGroups] = useState<GroupSummary[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const load = useCallback(async () => {
    if (!user) {
      setGroups([])
      setLoading(false)
      return
    }

    setLoading(true)
    setError(null)
    try {
      setGroups(await fetchUserGroups(user.id))
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Could not load groups.')
      setGroups([])
    } finally {
      setLoading(false)
    }
  }, [user])

  useEffect(() => {
    void load()
  }, [load])

  return { groups, loading, error, reload: load }
}
