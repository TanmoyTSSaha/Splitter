import { GroupsTab, HomeTab, LendingTab, MockCanvas, ProfileTab } from '../appmock'
import styles from './PhoneScreenStack.module.css'

const TABS = [HomeTab, GroupsTab, LendingTab, ProfileTab] as const

export type TabIndex = 0 | 1 | 2 | 3

type PhoneScreenStackProps = {
  initialTab?: TabIndex
  /** Static placements render one screen; only the tour needs all four. */
  single?: boolean
}

/**
 * For the tour, all four screens mount once and the scroll timeline toggles
 * `hidden` directly on the DOM. Hidden panels are never painted, and keeping
 * them mounted means the swap halfway through the spin costs nothing — no
 * React render and no remount hitch behind the phone's back.
 */
export function PhoneScreenStack({ initialTab = 0, single = false }: PhoneScreenStackProps) {
  const indices = single ? [initialTab] : ([0, 1, 2, 3] as TabIndex[])

  return (
    <div className={styles.viewport} data-motion="screen-stack">
      {indices.map((index) => {
        const Tab = TABS[index]
        return (
          <div
            key={index}
            className={styles.layer}
            data-tab-panel={index}
            hidden={index !== initialTab}
          >
            <MockCanvas>
              <Tab />
            </MockCanvas>
          </div>
        )
      })}
    </div>
  )
}
