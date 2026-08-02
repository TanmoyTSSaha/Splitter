const STORAGE_KEY = 'splitr_cookie_consent'

declare global {
  interface Window {
    dataLayer?: unknown[]
    gtag?: (...args: unknown[]) => void
  }
}

export function loadGa4(measurementId: string) {
  if (document.getElementById('ga4-script')) return

  window.dataLayer = window.dataLayer ?? []
  window.gtag = function gtag(...args: unknown[]) {
    window.dataLayer?.push(args)
  }
  window.gtag('js', new Date())
  window.gtag('config', measurementId)

  const script = document.createElement('script')
  script.id = 'ga4-script'
  script.async = true
  script.src = `https://www.googletagmanager.com/gtag/js?id=${measurementId}`
  document.head.appendChild(script)
}

export function getStoredConsent(): 'accepted' | 'rejected' | null {
  const value = localStorage.getItem(STORAGE_KEY)
  if (value === 'accepted' || value === 'rejected') return value
  return null
}

export function storeConsent(value: 'accepted' | 'rejected') {
  localStorage.setItem(STORAGE_KEY, value)
  const id = import.meta.env.VITE_GA4_MEASUREMENT_ID as string | undefined
  if (value === 'accepted' && id) {
    loadGa4(id)
  }
}

export function trackEvent(eventName: string, params?: Record<string, string>) {
  if (getStoredConsent() !== 'accepted' || typeof window.gtag !== 'function') return
  window.gtag('event', eventName, params)
}

export function trackInstallClick(location: string) {
  trackEvent('cta_install_click', { location })
  trackEvent('outbound_play_store', { location })
}

export function trackSignInClick(location: string) {
  trackEvent('cta_sign_in_click', { location })
}

export { STORAGE_KEY }
