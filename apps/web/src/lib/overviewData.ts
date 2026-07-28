import { supabase } from './supabase'
import type { OverviewBalances, OverviewTransaction } from './overview'
import { parseAmount, parseRate, toInr } from './money'

const INCOME_CATEGORIES = new Set(['salary', 'income', 'refund', 'interest'])

export async function fetchOverviewBalances(userId: string): Promise<OverviewBalances> {
  if (!supabase) return { youOwe: 0, youAreOwed: 0 }

  const memberRows = await supabase
    .from('group_members')
    .select('group_id')
    .eq('user_id', userId)

  const groupIds = (memberRows.data ?? []).map((row) => row.group_id as string)
  if (groupIds.length === 0) return { youOwe: 0, youAreOwed: 0 }

  const { data, error } = await supabase
    .from('group_balance')
    .select('donor_id, receiver_id, amount')
    .in('group_id', groupIds)

  if (error) throw error

  let youOwe = 0
  let youAreOwed = 0

  for (const row of data ?? []) {
    const amount = parseAmount(row.amount)
    if (row.receiver_id === userId) youOwe += amount
    if (row.donor_id === userId) youAreOwed += amount
  }

  return { youOwe, youAreOwed }
}

export async function fetchRecentTransactions(
  userId: string,
  limit = 10,
): Promise<OverviewTransaction[]> {
  if (!supabase) return []

  const [personalRes, groupRes] = await Promise.all([
    supabase
      .from('personal_transaction')
      .select(
        'id, amount, currency, exchange_rate_to_inr, category, transaction_description, transaction_date',
      )
      .eq('user_id', userId)
      .order('transaction_date', { ascending: false })
      .limit(limit),
    supabase
      .from('group_transaction')
      .select(
        'shared_transaction_amount, currency, exchange_rate_to_inr, paid_by, shared_with, transaction_group_id, transaction_date, description, category, group_id, groups(group_name)',
      )
      .or(`paid_by.eq.${userId},shared_with.eq.${userId}`)
      .order('transaction_date', { ascending: false })
      .limit(limit * 3),
  ])

  if (personalRes.error) throw personalRes.error
  if (groupRes.error) throw groupRes.error

  const unified: OverviewTransaction[] = []

  for (const txn of personalRes.data ?? []) {
    const category = String(txn.category ?? 'General')
    const isIncome = INCOME_CATEGORIES.has(category.toLowerCase())
    const amountInr = toInr(
      parseAmount(txn.amount),
      txn.currency as string | null,
      parseRate(txn.exchange_rate_to_inr),
    )

    unified.push({
      id: `personal-${txn.id as string}`,
      title: String(txn.transaction_description ?? 'Expense'),
      subtitle: category,
      amount: amountInr,
      date: String(txn.transaction_date),
      isCredit: isIncome,
      type: 'personal',
    })
  }

  const grouped = new Map<string, OverviewTransaction>()

  for (const txn of groupRes.data ?? []) {
    const groupId = String(txn.transaction_group_id ?? txn.group_id ?? txn.description)
    const paidBy = String(txn.paid_by)
    const isPayer = paidBy === userId
    const amountInr = toInr(
      parseAmount(txn.shared_transaction_amount),
      txn.currency as string | null,
      parseRate(txn.exchange_rate_to_inr),
    )
    const isSettlement = String(txn.category ?? '').toLowerCase() === 'settlement'
    const groups = txn.groups as { group_name?: string } | { group_name?: string }[] | null
    const groupName = Array.isArray(groups) ? groups[0]?.group_name : groups?.group_name

    if (!grouped.has(groupId)) {
      grouped.set(groupId, {
        id: `group-${groupId}`,
        title: String(txn.description ?? 'Group expense'),
        subtitle: isPayer ? 'You paid' : 'You owe',
        amount: 0,
        date: String(txn.transaction_date),
        isCredit: isPayer,
        type: 'group',
        context: groupName ?? undefined,
      })
    }

    const entry = grouped.get(groupId)!
    if (isPayer) {
      entry.amount += amountInr
      entry.isCredit = false
      entry.subtitle = 'You paid'
    } else {
      entry.amount += amountInr
      entry.isCredit = isSettlement
      entry.subtitle = isSettlement ? 'Settlement received' : 'You owe'
    }
  }

  unified.push(...grouped.values())
  unified.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())

  return unified.slice(0, limit)
}
