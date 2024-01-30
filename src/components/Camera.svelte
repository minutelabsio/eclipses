<script>
import * as THREE from 'three'
import CameraControls from 'camera-controls'
import { T, extend, useStage, useTask, useThrelte, forwardEventHandlers } from '@threlte/core'
import {
  FOV,
  sunPosition,
  moonDistance,
  altitude,
} from '../store/environment'

const component = forwardEventHandlers()
const { renderer, renderStage } = useThrelte()

const beforeRenderStage = useStage({
  before: renderStage
})

CameraControls.install( { THREE: THREE } )
extend({ CameraControls })
export let controls

$: controls?.moveTo(0, $altitude, -2, false)

useTask((dt) => {
  controls?.update(dt)
}, {
  stage: beforeRenderStage
})
</script>

<T.PerspectiveCamera
  position.z={2}
  fov={$FOV}
  near={1}
  far={1.2 * $moonDistance}
  bind:this={$component}
  let:ref
  {...$$restProps}
>
  <T.CameraControls
    args={[ref, renderer.domElement]}
    draggingSmoothTime={0.05}
    maxZoom={1}
    minZoom={1}
    minDistance={2}
    maxDistance={2.1}
    polarRotateSpeed={-0.08}
    azimuthRotateSpeed={-0.08}
    bind:ref={controls}
    on:create={({ ref }) => {
      const [x, y, z] = $sunPosition
      console.log('look in direction of', x, y, z)
      ref.lookInDirectionOf(x, y, z, false)
    }}
  />
</T.PerspectiveCamera>
