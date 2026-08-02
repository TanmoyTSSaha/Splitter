import { useEffect } from 'react'
import { trackEvent } from '../lib/analytics'

export function useSectionView(sectionId: string, sectionName: string) {
  useEffect(() => {
    const element = document.getElementById(sectionId)
    if (!element) return

    let seen = false
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (!entry?.isIntersecting || seen) return
        seen = true
        trackEvent('scroll_section_view', { section: sectionName })
      },
      { threshold: 0.2 },
    )

    observer.observe(element)
    return () => observer.disconnect()
  }, [sectionId, sectionName])
}
