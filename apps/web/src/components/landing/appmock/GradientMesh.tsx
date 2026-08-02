import type { ReactNode } from 'react'
import styles from './GradientMesh.module.css'

/**
 * Mirrors gradient_mesh_background.dart — four radial gradients at the same
 * relative offsets, radii and alphas, drifting on the same 8s loop.
 */
export function GradientMesh({
  children,
  className,
}: {
  children?: ReactNode
  className?: string
}) {
  return (
    <div className={`${styles.wrap} ${className ?? ''}`}>
      <div className={styles.mesh} />
      {children}
    </div>
  )
}
