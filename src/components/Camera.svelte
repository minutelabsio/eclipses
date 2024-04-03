<script>
import * as THREE from 'three'
import CameraControls from 'camera-controls'
import { T, extend, useStage, useTask, useThrelte, forwardEventHandlers } from '@threlte/core'
import {
  FOV,
  sunPosition,
  planetRadius,
  sunAngularDiameter,
  altitude,
  cameraStartPos,
} from '../store/environment'
import { onMount, tick } from 'svelte'
    import { DEG } from '../lib/units';

export let controls
export let telescope = false
export let orbitPlanet = false
export let animateTelescope = false
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

let followSun = false
let stateSaved = false

const updateCameraPosition = ([x, y, z]) => {
  if (!followSun) return
  if (!controls) return
  controls.lookInDirectionOf(x, y, z, animateTelescope)
  // a little shift to put sun higher in viewport
  controls.rotate(0, -0.25 * $sunAngularDiameter * DEG, false)
}

onMount(() => {
  const unsub = sunPosition.subscribe(updateCameraPosition)
  return unsub
})

const toggleTelecopeMode = async (camera, telescope) => {
  if (!camera || !controls) return
  if (telescope) {
    controls.saveState()
    stateSaved = true
    camera.up.set(0, Math.SQRT1_2, -Math.SQRT1_2)
    controls.updateCameraUp()
    controls.zoomTo(1, false)
    followSun = true
    updateCameraPosition($sunPosition)
  } else {
    followSun = false
    camera.up.set(0, 1, 0)
    controls.updateCameraUp()
    if (stateSaved){
      controls.reset()
      stateSaved = false
    }
  }
}

let zoom = 1

const onInteract = e => {
  zoom = controls._zoom
}

$: orbitPlanet ? setOrbit(camera, orbitPlanet) : controls?.moveTo(0, $altitude, -2, false)
$: controlsEnabled = !telescope
$: fov = telescope ? $sunAngularDiameter * 4 : $FOV
$: setOrbit(camera, orbitPlanet)
$: toggleTelecopeMode(camera, telescope)

useTask((dt) => {
  controls?.update(dt)
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
    maxZoom={50}
    minZoom={0.5}
    minDistance={2}
    maxDistance={2.1}
    smoothTime={0.1}
    polarRotateSpeed={orbitPlanet ? 0.5 / zoom : -0.08 / zoom}
    azimuthRotateSpeed={orbitPlanet ? 0.5 / zoom : -0.08 / zoom}
    mouseButtons.wheel={CameraControls.ACTION.ZOOM}
    touches.two={CameraControls.ACTION.TOUCH_ZOOM}
    bind:ref={controls}
    on:create={async ({ ref }) => {
      const [x, y, z] = $cameraStartPos
      ref.addEventListener('control', onInteract)
      await tick()
      ref.lookInDirectionOf(x, y, z, false)
    }}
  />
</T.PerspectiveCamera>
