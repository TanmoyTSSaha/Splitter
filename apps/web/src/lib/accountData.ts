import { supabase } from './supabase'

export type AccountProfile = {
  displayName: string
  email: string
  isPremium: boolean
}

export async function fetchAccountProfile(
  userId: string,
  fallbackEmail?: string | null,
): Promise<AccountProfile> {
  const fallbackName = fallbackEmail?.split('@')[0] ?? 'Splitr user'

  if (!supabase) {
    return {
      displayName: fallbackName,
      email: fallbackEmail ?? '',
      isPremium: false,
    }
  }

  const { data, error } = await supabase
    .from('users')
    .select('user_name, firstname, lastname, user_email, is_premium, premium_expires_at')
    .eq('user_id', userId)
    .maybeSingle()

  if (error) throw error

  if (!data) {
    return {
      displayName: fallbackName,
      email: fallbackEmail ?? '',
      isPremium: false,
    }
  }

  const displayName =
    String(data.user_name ?? '').trim() ||
    `${String(data.firstname ?? '').trim()} ${String(data.lastname ?? '').trim()}`.trim() ||
    fallbackName

  let isPremium = Boolean(data.is_premium)
  const expiresRaw = data.premium_expires_at
  if (isPremium && expiresRaw) {
    const expires = new Date(String(expiresRaw))
    if (!Number.isNaN(expires.getTime()) && expires < new Date()) {
      isPremium = false
    }
  }

  return {
    displayName,
    email: String(data.user_email ?? fallbackEmail ?? ''),
    isPremium,
  }
}
