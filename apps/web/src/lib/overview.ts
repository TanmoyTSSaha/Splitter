export type OverviewBalances = {
  youOwe: number
  youAreOwed: number
}

export type OverviewTransaction = {
  id: string
  title: string
  subtitle: string
  amount: number
  date: string
  isCredit: boolean
  type: 'personal' | 'group'
  context?: string
}
