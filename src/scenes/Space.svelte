<script>
  import { useFrame } from '@threlte/core'
  import { Easing, Tween } from 'intween'
  import Stats from '../components/Stats.svelte'
  import { T } from '@threlte/core'
  import { Vector3, MathUtils } from 'three'
  import createCorona from '../shaders/corona/Corona'
  import createStars from '../shaders/stars/Stars'
  import Sky from '../entities/Sky.svelte'
  import Mars from '../entities/Mars.svelte'
  import Earth from '../entities/Earth.svelte'
  import Jupiter from '../entities/Jupiter.svelte'
  import Saturn from '../entities/Saturn.svelte'
  import Neptune from '../entities/Neptune.svelte'
  import Uranus from '../entities/Uranus.svelte'
  import Renderer from '../components/Renderer.svelte'
  import Camera from '../components/Camera.svelte'
  import DebugControls from '../components/DebugControls.svelte'

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
    moonRightAscention,
    moonPosition,
    starsVisible,
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

  let starsPoints
  const Stars = createStars().then(s => starsPoints = s)

  let sunBrightness = 1
  $: sunsetBrightness = MathUtils.clamp(
      MathUtils.inverseLerp(-10, 3, $elevation),
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
  let cameraControls
  $: fog?.color.setHSL($fogHue / 360, .2, Easing.sinIn(sunBrightness) * 0.3)
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

{#if $planet === 'earth'}
<Earth
  visible={$earthVisible}
  mountainsVisible={$mountainsVisible}
  planetRadius={$planetRadius}
  position={[0, -$planetRadius, 0]}
  sunBrightness={sunBrightness}
  sunPosition={$sunPosition}
/>
{/if}
{#if $planet === 'mars'}
<Mars
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

  <!-- Sky -->
  <Sky/>

  <Saturn
    position={skyPosition(4.217e8, 13 * DEG, 20 * DEG)}
    rotation={[0, 0, 0]}
    planetRadius={7.1492e7}
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