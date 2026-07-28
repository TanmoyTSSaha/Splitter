import { useCallback, useEffect, useState } from 'react'
import { useAuth } from '../context/AuthContext'
import type { OverviewBalances, OverviewTransaction } from '../lib/overview'
import { fetchOverviewBalances, fetchRecentTransactions } from '../lib/overviewData'

type State = {
  balances: OverviewBalances
  transactions: OverviewTransaction[]
  loading: boolean
  error: string | null
}

const EMPTY: State = {
  balances: { youOwe: 0, youAreOwed: 0 },
  transactions: [],
  loading: true,
  error: null,
}

export function useOverviewData() {
  const { user } = useAuth()
  const [state, setState] = useState<State>(EMPTY)

  const load = useCallback(async () => {
    if (!user) {
      setState({ ...EMPTY, loading: false })
      return
    }

    setState((prev) => ({ ...prev, loading: true, error: null }))

    try {
      const [balances, transactions] = await Promise.all([
        fetchOverviewBalances(user.id),
        fetchRecentTransactions(user.id),
      ])
      setState({ balances, transactions, loading: false, error: null })
    } catch (err) {
      setState({
        ...EMPTY,
        loading: false,
        error: err instanceof Error ? err.message : 'Could not load overview.',
      })
    }
  }, [user])

  useEffect(() => {
    void load()
  }, [load])

  return { ...state, reload: load }
}
