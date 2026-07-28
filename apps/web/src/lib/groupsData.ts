import { supabase } from './supabase'
import { formatInr, parseAmount, parseRate, toInr } from './money'

export type GroupBalanceEntry = {
  donorId: string
  donorName: string
  receiverId: string
  receiverName: string
  amount: number
}

export type GroupSummary = {
  id: string
  name: string
  netBalance: number
  memberCount: number
}

export type GroupMember = {
  id: string
  name: string
}

export type GroupExpense = {
  id: string
  title: string
  amount: number
  date: string
  paidByName: string
}

export type GroupDetail = {
  id: string
  name: string
  netBalance: number
  members: GroupMember[]
  balances: GroupBalanceEntry[]
  expenses: GroupExpense[]
}

type RawBalance = {
  donor_id?: string
  donor?: string
  receiver_id?: string
  receiver?: string
  amount?: unknown
}

function netBalanceForUser(balances: RawBalance[], userId: string): number {
  let paid = 0
  let received = 0
  for (const row of balances) {
    const amount = parseAmount(row.amount)
    if (row.donor_id === userId) paid += amount
    if (row.receiver_id === userId) received += amount
  }
  return received - paid
}

export function parseBalances(raw: unknown): RawBalance[] {
  if (!Array.isArray(raw)) return []
  return raw as RawBalance[]
}

export async function fetchUserGroups(userId: string): Promise<GroupSummary[]> {
  if (!supabase) return []

  const { data: memberships, error: memberError } = await supabase
    .from('group_members')
    .select('group_id')
    .eq('user_id', userId)

  if (memberError) throw memberError

  const groupIds = (memberships ?? []).map((row) => row.group_id as string)
  if (groupIds.length === 0) return []

  const { data: groups, error: groupError } = await supabase
    .from('groups')
    .select('group_id, group_name, group_balance')
    .in('group_id', groupIds)
    .order('group_name', { ascending: true })

  if (groupError) throw groupError

  const { data: memberCounts, error: countError } = await supabase
    .from('group_members')
    .select('group_id')
    .in('group_id', groupIds)

  if (countError) throw countError

  const counts = new Map<string, number>()
  for (const row of memberCounts ?? []) {
    const id = row.group_id as string
    counts.set(id, (counts.get(id) ?? 0) + 1)
  }

  return (groups ?? []).map((group) => {
    const balances = parseBalances(group.group_balance)
    return {
      id: group.group_id as string,
      name: String(group.group_name ?? 'Group'),
      netBalance: netBalanceForUser(balances, userId),
      memberCount: counts.get(group.group_id as string) ?? 0,
    }
  })
}

export async function fetchGroupDetail(
  userId: string,
  groupId: string,
): Promise<GroupDetail | null> {
  if (!supabase) return null

  const { data: membership, error: memberError } = await supabase
    .from('group_members')
    .select('group_id')
    .eq('user_id', userId)
    .eq('group_id', groupId)
    .maybeSingle()

  if (memberError) throw memberError
  if (!membership) return null

  const { data: group, error: groupError } = await supabase
    .from('groups')
    .select('group_id, group_name, group_balance')
    .eq('group_id', groupId)
    .single()

  if (groupError) throw groupError

  const { data: memberRows, error: membersError } = await supabase
    .from('group_members')
    .select('user_id')
    .eq('group_id', groupId)

  if (membersError) throw membersError

  const memberIds = (memberRows ?? []).map((row) => row.user_id as string)
  const userNameById = new Map<string, string>()

  if (memberIds.length > 0) {
    const { data: users, error: usersError } = await supabase
      .from('users')
      .select('user_id, user_name, firstname, lastname')
      .in('user_id', memberIds)

    if (usersError) throw usersError

    for (const user of users ?? []) {
      const name =
        String(user.user_name ?? '').trim() ||
        `${String(user.firstname ?? '').trim()} ${String(user.lastname ?? '').trim()}`.trim() ||
        'Member'
      userNameById.set(user.user_id as string, name)
    }
  }

  const members: GroupMember[] = memberIds.map((id) => ({
    id,
    name: userNameById.get(id) ?? 'Member',
  }))

  const balances: GroupBalanceEntry[] = parseBalances(group.group_balance).map((row) => ({
    donorId: String(row.donor_id ?? ''),
    donorName: String(row.donor ?? userNameById.get(String(row.donor_id)) ?? 'Member'),
    receiverId: String(row.receiver_id ?? ''),
    receiverName: String(row.receiver ?? userNameById.get(String(row.receiver_id)) ?? 'Member'),
    amount: parseAmount(row.amount),
  }))

  const { data: txns, error: txnError } = await supabase
    .from('group_transaction')
    .select(
      'transaction_group_id, shared_transaction_amount, currency, exchange_rate_to_inr, paid_by, transaction_date, description',
    )
    .eq('group_id', groupId)
    .order('transaction_date', { ascending: false })
    .limit(60)

  if (txnError) throw txnError

  const expenseMap = new Map<string, GroupExpense>()

  for (const txn of txns ?? []) {
    const key = String(txn.transaction_group_id ?? txn.description)
    const amountInr = toInr(
      parseAmount(txn.shared_transaction_amount),
      txn.currency as string | null,
      parseRate(txn.exchange_rate_to_inr),
    )
    const paidBy = String(txn.paid_by)
    const existing = expenseMap.get(key)

    if (!existing) {
      expenseMap.set(key, {
        id: key,
        title: String(txn.description ?? 'Expense'),
        amount: amountInr,
        date: String(txn.transaction_date),
        paidByName: userNameById.get(paidBy) ?? 'Member',
      })
    } else {
      existing.amount += amountInr
    }
  }

  const expenses = [...expenseMap.values()].sort(
    (a, b) => new Date(b.date).getTime() - new Date(a.date).getTime(),
  )

  return {
    id: group.group_id as string,
    name: String(group.group_name ?? 'Group'),
    netBalance: netBalanceForUser(parseBalances(group.group_balance), userId),
    members,
    balances,
    expenses: expenses.slice(0, 20),
  }
}

export function formatSignedBalance(net: number): string {
  const prefix = net > 0 ? '+' : net < 0 ? '−' : ''
  return `${prefix}${formatInr(Math.abs(net))}`
}
