import type { TabIndex } from '../phone/PhoneScreenStack'

export type TourBeat = {
  tab: TabIndex
  /** Which side of the stage the phone rests on for this beat */
  phoneSide: 'right' | 'left' | 'center'
  /**
   * `hero` beats use the centred HeroCopy block instead of a TourCopyPanel.
   * Omitted for the four product-tour beats.
   */
  copy?: 'hero'
  eyebrow: string
  title: string
  body: string
  points: string[]
}

export const TOUR_BEATS: TourBeat[] = [
  {
    tab: 0,
    phoneSide: 'center',
    copy: 'hero',
    eyebrow: 'Expense splitting for friends & groups',
    title: 'Split. Track. Settle.',
    body: 'Personal finance home — monthly spend, transactions, and goals in one app built for India.',
    points: [],
  },
  {
    tab: 0,
    phoneSide: 'right',
    eyebrow: 'Home',
    title: 'Every rupee, one screen.',
    body: 'Personal spends and your share of group bills land in the same feed, already converted to your currency.',
    points: [
      'Top five spend categories for the month',
      'True Spend and Cash Flow side by side',
      'Goals tracked against what you actually spent',
    ],
  },
  {
    tab: 1,
    phoneSide: 'left',
    eyebrow: 'Groups',
    title: 'Split it without the spreadsheet.',
    body: 'Flatmates, trips, one-off dinners — Splitr keeps who-owes-who current after every expense.',
    points: [
      'Equal, exact, share or percentage splits',
      'Owed and owing totals at a glance',
      'Settle up over UPI and close the loop',
    ],
  },
  {
    tab: 2,
    phoneSide: 'right',
    eyebrow: 'Lending',
    title: 'Loans between friends, on the record.',
    body: 'Turn a favour into a contract both sides accept, with interest, a due date and a repayment schedule.',
    points: [
      'Simple, compound or flat interest',
      'Repayment progress, principal versus interest',
      'Active, pending and completed in one place',
    ],
  },
  {
    tab: 3,
    phoneSide: 'left',
    eyebrow: 'Profile',
    title: 'Your money, year-round.',
    body: 'Achievements, spending insights and a monthly recap that tells you what actually changed.',
    points: [
      'Total spent and received at a glance',
      'Expense insights and unusual-spend alerts',
      'Monthly recap, delivered as a story',
    ],
  },
]
