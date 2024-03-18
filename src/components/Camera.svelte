<script>
import * as THREE from 'three'
import CameraControls from 'camera-controls'
import { T, extend, useStage, useTask, useThrelte, forwardEventHandlers } from '@threlte/core'
import {
  FOV,
  sunPosition,
  moonDistance,
  planetRadius,
  sunAngularDiameter,
  altitude,
} from '../store/environment'

export let controls
export let telescope = false
export let orbitPlanet = false
let camera

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

const setOrbit = (camera, orbitPlanet) => {
  if (!camera || !controls) return
  if (orbitPlanet){
    camera.up.set(1, 0, 0)
    controls.updateCameraUp()
    controls?.setLookAt(0, $altitude, -2, 0, -$planetRadius, 0)
  } else {
    camera.up.set(0, 1, 0)
    controls.updateCameraUp()
    controls?.setLookAt(0, $altitude, -2, 0, $altitude, 0)
  }
}

const setTelescopeUp = (camera, telescope) => {
  if (!camera || !controls) return
  if (telescope){
    camera.up.set(0, Math.SQRT1_2, -Math.SQRT1_2)
    controls.updateCameraUp()
  } else {
    camera.up.set(0, 1, 0)
    controls.updateCameraUp()
  }
}

$: orbitPlanet ? setOrbit(camera, orbitPlanet) : controls?.moveTo(0, $altitude, -2, false)
$: controlsEnabled = !telescope
$: fov = telescope ? $sunAngularDiameter * 4 : $FOV
$: setOrbit(camera, orbitPlanet)
$: setTelescopeUp(camera, telescope)

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
  bind:ref={camera}
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
    polarRotateSpeed={orbitPlanet ? 0.5 : -0.08}
    azimuthRotateSpeed={orbitPlanet ? 0.5 : -0.08}
    bind:ref={controls}
    on:create={({ ref }) => {
      const [x, y, z] = $sunPosition
      ref.lookInDirectionOf(x, y, z, false)
    }}
  />
</T.PerspectiveCamera>
