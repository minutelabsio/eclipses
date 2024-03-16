<script>
  import { useFrame } from '@threlte/core'
  import { Easing, Tween } from 'intween'
  import { T } from '@threlte/core'
  import { Vector3, MathUtils } from 'three'
  import createCorona from '../shaders/corona/Corona'
  import createStars from '../shaders/stars/Stars'
  import Sky from '../entities/Sky.svelte'
  import MarsScene from '../entities/MarsScene.svelte'
  import EarthScene from '../entities/EarthScene.svelte'
  import Jupiter from '../entities/Jupiter.svelte'
  import Saturn from '../entities/Saturn.svelte'
  import Neptune from '../entities/Neptune.svelte'
  import Uranus from '../entities/Uranus.svelte'

  import {
    planet,
    planetRadius,
    eclipseProgress,
    doAnimation,
    elevationRad,
    totalityFactor,
    sunPosition,
    sunRadius,
    moonRadius,
    moonDistance,
    moonRightAscention,
    moonAngularDiameter,
    moonPosition,
    starsVisible,
    mountainsVisible,
    earthVisible,
    elevation,
    fogHue,
    overrideRA,
    sunAngularDiameter,
    moonOrbitDirection,
  } from '../store/environment'
  import {
    DEG,
  } from '../lib/units'

  const Corona = createCorona({
    opacity: 0.5
  })

  let starsPoints
  const Stars = createStars().then(s => starsPoints = s)

  let sunBrightness = 1
  $: sunsetBrightness = MathUtils.clamp(
      MathUtils.inverseLerp(-6, 3, $elevation),
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
  $: moveDegrees = $moonOrbitDirection * $moonAngularDiameter
  $: minBrightness = Math.max(0, 1 - $moonAngularDiameter * $moonAngularDiameter / ($sunAngularDiameter * $sunAngularDiameter))
  $: moonMove = new Tween({ theta: -moveDegrees, corona: minCoronaOpacity, brightness: 1 })
    .by('2s', { theta: 0 }, 'linear')
    .by('2s', { brightness: minBrightness }, lightIn)
    .by('2s', { corona: maxCoronaOpacity }, expoIn)
    .by('4s', { theta: moveDegrees }, 'linear')
    .by('4s', { brightness: 1.0 }, lightOut)
    .by('4s', { corona: minCoronaOpacity }, expoOut)
    .by('6s', { theta: 0 }, 'linear')
    .by('6s', { brightness: minBrightness }, lightIn)
    .by('6s', { corona: maxCoronaOpacity }, expoIn)
    .by('8s', { theta: -moveDegrees }, 'linear')
    .by('8s', { brightness: 1.0 }, lightOut)
    .by('8s', { corona: minCoronaOpacity }, expoOut)
    .loop()

  $: angleLimit = Math.asin($planetRadius / $moonDistance)

  let time = 0
  useFrame((ctx, dt) => {
    // frame
    if ($doAnimation) {
      time += dt * 1000
    } else {
      time = $eclipseProgress * moonMove.duration
    }
    // controls?.update(window.performance.now())
    const state = moonMove.at(time / 2)
    sunBrightness = state.brightness * sunsetBrightness
    const RA = $overrideRA ? MathUtils.lerp(-angleLimit, angleLimit, $eclipseProgress) : state.theta * DEG
    moonRightAscention.set(RA)
  })

  let fog
  $: fog?.color.setHSL($fogHue / 360, .2, Easing.sinIn(sunBrightness) * 0.3)
</script>

<T.FogExp2 attach="fog" bind:ref={fog} density={1.5e-5} layers={9}/>

{#await Stars then Stars}
<T.Group rotation={[-$elevationRad, 0, 0]}>
  <T is={Stars} renderOrder={0} visible={$starsVisible} rotation={[0, -.52, -0.53]}/>
</T.Group>
{/await}

{#if $planet === 'earth'}
<EarthScene
  visible={$earthVisible}
  mountainsVisible={$mountainsVisible}
  planetRadius={$planetRadius}
  position={[0, -$planetRadius, 0]}
  sunBrightness={sunBrightness}
  sunPosition={$sunPosition}
/>
{/if}
{#if $planet === 'mars'}
<MarsScene
  visible={$earthVisible}
  mountainsVisible={$mountainsVisible}
  planetRadius={$planetRadius}
  position={[0, -$planetRadius, 0]}
  sunBrightness={sunBrightness}
  sunPosition={$sunPosition}
/>
{/if}
{#if $planet === 'jupiter'}
<Jupiter
  visible={$earthVisible}
  planetRadius={$planetRadius}
  position={[0, -$planetRadius, 0]}
/>
{/if}
{#if $planet === 'saturn'}
<Saturn
  visible={$earthVisible}
  planetRadius={$planetRadius}
  position={[0, -$planetRadius, 0]}
/>
{/if}
{#if $planet === 'neptune'}
<Neptune
  visible={$earthVisible}
  planetRadius={$planetRadius}
  position={[0, -$planetRadius, 0]}
/>
{/if}
{#if $planet === 'uranus'}
<Uranus
  visible={$earthVisible}
  planetRadius={$planetRadius}
  position={[0, -$planetRadius, 0]}
/>
{/if}

<T.Group
  position={[0, -$planetRadius, 0]}
>
  <T.DirectionalLight
    intensity={1}
    position={$sunPosition}
  />

  <!-- Sky -->
  <Sky/>

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
    <T.MeshBasicMaterial color="green" fog={false} />
  </T.Mesh>
</T.Group>