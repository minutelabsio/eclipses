<script>
  import { useFrame } from '@threlte/core'
  import { Easing, Tween } from 'intween'
  import Stats from '../components/Stats.svelte'
  import { T } from '@threlte/core'
  import { Vector3, MathUtils } from 'three'
  import createCorona from '../shaders/corona/Corona'
  import createSky from '../shaders/sky/Sky'
  import createStars from '../shaders/stars/Stars'
  import Earth from '../entities/Earth.svelte'
  import Jupiter from '../entities/Jupiter.svelte'
  import Renderer from '../components/Renderer.svelte'
  import Camera from '../components/Camera.svelte'
  import DebugControls from '../components/DebugControls.svelte'

  import {
    planetRadius,
    eclipseProgress,
    doAnimation,
    atmosphereThickness,
    airIndexRefraction,
    elevationRad,
    totalityFactor,
    sunIntensity,
    sunPosition,
    sunRadius,
    sunDistance,
    moonRadius,
    moonRightAscention,
    moonPosition,
    rayleighCoefficient,
    rayleighScaleHeight,
    mieCoefficient,
    mieWavelengthResponse,
    mieScaleHeight,
    mieDirectional,
    exposure,
    iSteps,
    jSteps,
    cloudZ,
    cloudThickness,
    cloudSize,
    cloudMie,
    cloudThreshold,
    cloudAbsorption,
    windSpeed,
    starsVisible,
    skyVisible,
    mountainsVisible,
    earthVisible,
    elevation,
    fogHue,
  } from '../store/environment'
  import {
    DEG,
    METER,
    AU,
  } from '../lib/units'
  import { skyPosition } from '../lib/sky-position'

  const Corona = createCorona({
    opacity: 0.5
  })

  const Sky = createSky()

  let starsPoints
  const Stars = createStars().then(s => starsPoints = s)

  let sunBrightness = 1
  $: sunsetBrightness = MathUtils.clamp(
      MathUtils.inverseLerp(-10, 10, $elevation) * Math.pow(AU / $sunDistance, 2),
      0, 1
    )

  const createExpotentialIn = (a) => {
    return (x) => Math.pow(2, a * x - a) * x
  }

  const createExpotentialOut = (a) => {
    return (x) => 1 - Math.pow(2, -a * x) * (1 - x)
  }

  $: maxCoronaOpacity = $totalityFactor * 0.09
  let minCoronaOpacity = 0.06

  const expoIn = createExpotentialIn(10)
  const expoOut = createExpotentialOut(10)
  const lightIn = 'quadInOut'
  const lightOut = 'quadInOut'
  $: moonMove = new Tween({ theta: -0.8, corona: minCoronaOpacity, brightness: 1 })
    .by('2s', { theta: 0 }, 'quadOut')
    .by('2s', { brightness: 0.01 }, lightIn)
    .by('2s', { corona: maxCoronaOpacity }, expoIn)
    .by('4s', { theta: 0.8 }, 'quadIn')
    .by('4s', { brightness: 1.0 }, lightOut)
    .by('4s', { corona: minCoronaOpacity }, expoOut)
    .by('6s', { theta: 0 }, 'quadOut')
    .by('6s', { brightness: 0.01 }, lightIn)
    .by('6s', { corona: maxCoronaOpacity }, expoIn)
    .by('8s', { theta: -0.8 }, 'quadIn')
    .by('8s', { brightness: 1.0 }, lightOut)
    .by('8s', { corona: minCoronaOpacity }, expoOut)
    .loop()

  let time = 0
  useFrame((ctx, dt) => {
    // frame
    Sky.update(dt)
    if ($doAnimation) {
      time += dt * 1000
    } else {
      time = $eclipseProgress * moonMove.duration
    }
    // controls?.update(window.performance.now())
    const state = moonMove.at(time / 2)
    moonRightAscention.set(state.theta * DEG)
    sunBrightness = state.brightness * sunsetBrightness
  })

  let fog

  $: Sky.sunIntensity = $sunIntensity
  $: Sky.rayleighCoefficients = $rayleighCoefficient
  $: Sky.rayleighScaleHeight = $rayleighScaleHeight
  $: Sky.mieCoefficients = $mieCoefficient
  $: Sky.mieWavelengthResponse = $mieWavelengthResponse
  $: Sky.mieScaleHeight = $mieScaleHeight
  $: Sky.mieDirectional = $mieDirectional
  $: Sky.exposure = $exposure
  $: Sky.iSteps = $iSteps
  $: Sky.jSteps = $jSteps
  $: Sky.cloudZ = $cloudZ
  $: Sky.cloudThickness = $cloudThickness
  $: Sky.cloudSize = $cloudSize
  $: Sky.cloudMie = $cloudMie
  $: Sky.cloudThreshold = $cloudThreshold
  $: Sky.cloudAbsorption = $cloudAbsorption
  $: Sky.windSpeed = $windSpeed
  $: Sky.atmosphereThickness = $atmosphereThickness
  $: Sky.planetRadius = $planetRadius
  $: Sky.sunPosition.set(...$sunPosition)
  $: Sky.sunRadius = $sunRadius / METER
  $: Sky.moonPosition.copy($moonPosition)
  $: Sky.moonRadius = $moonRadius / METER
  $: fog?.color.setHSL($fogHue / 360, .2, Easing.sinIn(sunBrightness) * 0.3)

  let cameraControls
</script>


<DebugControls cameraControls={cameraControls}/>
<Renderer/>
<Stats />

<T.FogExp2 attach="fog" bind:ref={fog} density={1.5e-5} layers={9}/>

{#await Stars then Stars}
<T is={Stars} renderOrder={0} visible={$starsVisible}/>
{/await}

<Camera
  makeDefault
  near={1}
  far={1.2 * AU}
  bind:controls={cameraControls}
/>

<Earth
  planetVisible={$earthVisible}
  mountainsVisible={$mountainsVisible}
  planetRadius={$planetRadius}
  position={[0, -$planetRadius, 0]}
  sunBrightness={sunBrightness}
  sunPosition={$sunPosition}
/>

<T.Group
  position={[0, -$planetRadius, 0]}
>

  <T.DirectionalLight
    intensity={1}
    position={$sunPosition}
  />
  <!-- Corona -->
  <T.Mesh
    visible={false}
    position={$sunPosition}
    rotation.x={-$elevationRad}
    rotation.y={Math.PI}
    scale={[$sunRadius, $sunRadius, $sunRadius]}
    renderOrder={2}
  >
    <T.PlaneGeometry args={[4.4, 4.32]} />
    <T is={Corona}/>
  </T.Mesh>

  <T.Mesh
    visible={$skyVisible}
    scale.x={$planetRadius + $atmosphereThickness}
    scale.y={$planetRadius + $atmosphereThickness}
    scale.z={$planetRadius + $atmosphereThickness}
    renderOrder={2}
  >
    <T.IcosahedronGeometry args={[1, 32]} />
    <T is={Sky.shader} />
  </T.Mesh>

  <Jupiter
    position={skyPosition(4.217e8, 13 * DEG, 20 * DEG)}
    radius={7.1492e7}
  />

  <!-- moon debug -->
  <T.Mesh
    visible={false}
    position={$moonPosition.toArray()}
    rotation={[180 * DEG, 0, 0]}
  >
    <!-- <T.SphereGeometry args={[moonRadius, 32, 32]} /> -->
    <T.IcosahedronGeometry args={[$moonRadius, 32]} />
    <!-- <T.CircleGeometry args={[moonRadius, 32]} /> -->
    <T.MeshBasicMaterial color="red" dithering fog={false} />
  </T.Mesh>

  <!-- Sun Debug -->
  <T.Mesh
    visible={false}
    position={$sunPosition}
  >
    <T.IcosahedronGeometry args={[$sunRadius, 32]} />
    <T.MeshBasicMaterial color="green" dithering fog={false} />
  </T.Mesh>
</T.Group>