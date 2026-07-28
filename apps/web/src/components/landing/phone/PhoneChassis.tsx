import type { CSSProperties } from 'react'
import { NothingPhone1Back } from './NothingPhone1Back'
import { PhoneScreenStack, type TabIndex } from './PhoneScreenStack'
import {
  BODY_H,
  BODY_RADIUS,
  BODY_W,
  DEPTH,
  SCREEN_RADIUS,
  SCREEN_W,
} from './phoneGeometry'
import styles from './PhoneChassis.module.css'

const halfW = BODY_W / 2
const halfH = BODY_H / 2
const halfD = DEPTH / 2

type PhoneChassisProps = {
  initialTab?: TabIndex
  /** Front-only rendering for the mobile fallback, where there is no spin. */
  frontOnly?: boolean
  /** Overrides the 324px desktop body width; the screen scales with it. */
  width?: number
}

export function PhoneChassis({ initialTab = 0, frontOnly = false, width }: PhoneChassisProps) {
  const scale = width ? width / BODY_W : 1

  return (
    <div
      className={styles.chassis}
      style={
        {
          width: `${BODY_W}px`,
          height: `${BODY_H}px`,
          borderRadius: `${BODY_RADIUS}px`,
          '--body-radius': `${BODY_RADIUS}px`,
          '--screen-radius': `${SCREEN_RADIUS}px`,
          '--phone-screen-w': SCREEN_W,
          ...(scale === 1 ? null : { transform: `scale(${scale})` }),
        } as CSSProperties
      }
    >
      <div className={styles.faceFront} style={{ transform: `translateZ(${halfD}px)` }}>
        <div className={styles.frontBody}>
          <div className={styles.screenViewport} data-motion="phone-screen">
            <PhoneScreenStack initialTab={initialTab} single={frontOnly} />
          </div>
        </div>
      </div>

      {frontOnly ? null : (
        <>
          <div
            className={styles.faceBack}
            style={{ transform: `rotateY(180deg) translateZ(${halfD}px)` }}
          >
            <NothingPhone1Back />
          </div>

          <div
            className={styles.faceSide}
            style={{
              transform: `rotateY(-90deg) translateZ(${halfW}px)`,
              width: `${DEPTH}px`,
              marginLeft: `${-halfD}px`,
            }}
          />
          <div
            className={styles.faceSide}
            style={{
              transform: `rotateY(90deg) translateZ(${halfW}px)`,
              width: `${DEPTH}px`,
              marginLeft: `${-halfD}px`,
            }}
          />
          <div
            className={styles.faceCap}
            style={{
              transform: `rotateX(90deg) translateZ(${halfH}px)`,
              height: `${DEPTH}px`,
              marginTop: `${-halfD}px`,
            }}
          />
          <div
            className={styles.faceCap}
            style={{
              transform: `rotateX(-90deg) translateZ(${halfH}px)`,
              height: `${DEPTH}px`,
              marginTop: `${-halfD}px`,
            }}
          />
        </>
      )}
    </div>
  )
}
