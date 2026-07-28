import { useAuth } from '../../context/AuthContext'
import { useAccountProfile } from '../../hooks/useAccountProfile'
import { usePageMeta } from '../../hooks/usePageMeta'
import { Button } from '../../components/Button'
import { BlockedActionBanner } from '../../components/app/BlockedActionBanner'
import { ErrorCard } from '../../components/app/ErrorCard'
import { ProBadge } from '../../components/app/ProBadge'
import { SettingsRow } from '../../components/app/SettingsRow'
import { LEGAL_ROUTES } from '../../constants/site'
import styles from '../../components/app/Account.module.css'

const SETTINGS = [
  { label: 'Edit profile', href: 'splitr://' },
  { label: 'Manage Pro', href: 'splitr://' },
  { label: 'Delete account', href: 'splitr://' },
] as const

export function AccountPage() {
  const { signOut } = useAuth()
  const { profile, loading, error, reload } = useAccountProfile()

  usePageMeta('Account', 'Your Splitr account on the web.', '/app/account', { noIndex: true })

  if (loading) {
    return (
      <div aria-busy="true" aria-label="Loading account">
        <div className={styles.skeleton} />
      </div>
    )
  }

  const displayName = profile?.displayName ?? 'Splitr user'
  const email = profile?.email ?? ''

  return (
    <div>
      <div className={styles.card}>
        <div className={styles.avatar} aria-hidden>
          {displayName.charAt(0).toUpperCase()}
        </div>
        <div className={styles.nameRow}>
          <h2 className={styles.name}>{displayName}</h2>
          {profile?.isPremium ? <ProBadge /> : null}
        </div>
        <p className={styles.email}>{email}</p>
      </div>

      {error ? (
        <ErrorCard message={error} onRetry={() => void reload()} />
      ) : null}

      <BlockedActionBanner />

      <ul className={styles.list} aria-label="Account settings">
        {SETTINGS.map((item) => (
          <SettingsRow key={item.label} label={item.label} href={item.href} />
        ))}
        <SettingsRow
          label="Account deletion policy"
          hint="Read how to request deletion"
          href={LEGAL_ROUTES.accountDeletion}
        />
      </ul>

      <Button type="button" variant="danger" onClick={() => void signOut()}>
        Sign out
      </Button>
    </div>
  )
}
