import { BODY_H } from '../../components/landing/phone/phoneGeometry'

/** Vertical room the phone must leave for the nav and section breathing space. */
const VERTICAL_CHROME = 140

export function computePhoneFit(): number {
  const available = window.innerHeight - VERTICAL_CHROME
  return Math.max(0.6, Math.min(1, available / BODY_H))
}
