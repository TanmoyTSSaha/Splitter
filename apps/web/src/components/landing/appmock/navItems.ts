import type { IconVariant } from './Icon'

export type NavItem = {
  label: string
  icon: string
  outlineVariant: IconVariant
  filledVariant: IconVariant
}

/** Matches the items list in bottom_navigation_controller.dart */
export const NAV_ITEMS: NavItem[] = [
  { label: 'Home', icon: 'home', outlineVariant: 'outlined', filledVariant: 'round' },
  { label: 'Groups', icon: 'groups_2', outlineVariant: 'outlined', filledVariant: 'round' },
  {
    label: 'Lending',
    icon: 'account_balance_wallet',
    outlineVariant: 'outlined',
    filledVariant: 'filled',
  },
  { label: 'Profile', icon: 'person', outlineVariant: 'outlined', filledVariant: 'round' },
]
