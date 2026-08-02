/**
 * Derived from the real Nothing Phone (1): 159.2 x 75.8 x 8.3 mm body around a
 * 20:9 display. The screen is authored at the app's logical 411x914 dp so the
 * MockCanvas drops in with zero letterboxing.
 */
export const SCREEN_W = 300
export const SCREEN_H = (SCREEN_W * 914) / 411

export const BEZEL = 12
export const BODY_W = SCREEN_W + BEZEL * 2
export const BODY_H = SCREEN_H + BEZEL * 2

/** 8.3mm / 75.8mm of the body width */
export const DEPTH = Math.round(BODY_W * (8.3 / 75.8))

/**
 * Circle fit against the render's top-left corner gives r ≈ 15% of the body
 * width. Kept a shade under that so the rounded clip never bites into the
 * aluminium rail.
 */
export const BODY_RADIUS = Math.round(BODY_W * 0.142)
export const SCREEN_RADIUS = BODY_RADIUS - BEZEL

/**
 * Body bounds measured in phone/nothing-phone-1-back.png (473x1024): the
 * aluminium frame spans x 64..406, y 157..869.
 */
export const BACK_RENDER = {
  imageW: 473,
  imageH: 1024,
  bodyX: 64,
  bodyY: 157,
  bodyW: 343,
  bodyH: 713,
} as const
