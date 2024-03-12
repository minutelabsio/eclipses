<script>
import * as THREE from 'three'
import CameraControls from 'camera-controls'
import { T, extend, useStage, useTask, useThrelte, forwardEventHandlers } from '@threlte/core'
import {
  FOV,
  sunPosition,
  moonDistance,
  sunAngularDiameter,
  altitude,
} from '../store/environment'

export let telescope = true
const component = forwardEventHandlers()
const { renderer, renderStage } = useThrelte()

const beforeRenderStage = useStage({
  before: renderStage
})

CameraControls.install( { THREE: THREE } )
CameraControls.prototype.lookInDirectionOf = function(x, y, z, anim) {
  const point = new THREE.Vector3(x, y, z);
  const direction = point.sub( this._targetEnd ).normalize();
  const position = direction.multiplyScalar( - this._sphericalEnd.radius ).add( this._targetEnd );
  return this.setPosition( position.x, position.y, position.z, anim );
}
extend({ CameraControls })
export let controls

$: controls?.moveTo(0, $altitude, -2, false)
$: controlsEnabled = !telescope
$: fov = telescope ? $sunAngularDiameter * 4 : $FOV

useTask((dt) => {
  controls?.update(dt)
}, {
  stage: beforeRenderStage
})
</script>

<T.PerspectiveCamera
  position.z={2}
  fov={fov}
  bind:this={$component}
  let:ref
  {...$$restProps}
>
  <T.CameraControls
    args={[ref, renderer.domElement]}
    enabled={controlsEnabled}
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
      ref.lookInDirectionOf(x, y, z, false)
    }}
  />
</T.PerspectiveCamera>
