import { useEffect } from 'react'
import { DEFAULT_OG_IMAGE, SITE_URL } from '../constants/site'

type Options = {
  image?: string
  noIndex?: boolean
}

function upsertMeta(attr: 'name' | 'property', key: string, content: string) {
  let el = document.querySelector(`meta[${attr}="${key}"]`)
  if (!el) {
    el = document.createElement('meta')
    el.setAttribute(attr, key)
    document.head.appendChild(el)
  }
  el.setAttribute('content', content)
}

function upsertLink(rel: string, href: string) {
  let el = document.querySelector(`link[rel="${rel}"]`)
  if (!el) {
    el = document.createElement('link')
    el.setAttribute('rel', rel)
    document.head.appendChild(el)
  }
  el.setAttribute('href', href)
}

export function usePageMeta(
  title: string,
  description: string,
  path: string,
  options: Options = {},
) {
  useEffect(() => {
    const documentTitle = title.startsWith('Splitr') ? title : `${title} — Splitr`
    const canonicalUrl = `${SITE_URL}${path}`
    const image = options.image ?? DEFAULT_OG_IMAGE

    document.title = documentTitle

    upsertMeta('name', 'description', description)
    upsertLink('canonical', canonicalUrl)

    upsertMeta('property', 'og:title', documentTitle)
    upsertMeta('property', 'og:description', description)
    upsertMeta('property', 'og:url', canonicalUrl)
    upsertMeta('property', 'og:image', image)
    upsertMeta('property', 'og:type', 'website')

    upsertMeta('name', 'twitter:card', 'summary_large_image')
    upsertMeta('name', 'twitter:title', documentTitle)
    upsertMeta('name', 'twitter:description', description)
    upsertMeta('name', 'twitter:image', image)

    if (options.noIndex) {
      upsertMeta('name', 'robots', 'noindex, nofollow')
    } else {
      document.querySelector('meta[name="robots"]')?.remove()
    }
  }, [title, description, path, options.image, options.noIndex])
}
