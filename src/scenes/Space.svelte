<script>
  import { useFrame } from '@threlte/core'
  import { Easing, Tween } from 'intween'
  import { T } from '@threlte/core'
  import { Vector3, MathUtils } from 'three'
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
    sunPosition,
    moonDistance,
    moonRightAscention,
    starsVisible,
    mountainsVisible,
    earthVisible,
    overrideRA,
    moonTransitDegrees,
    moonAngleCorrection,
    sunBrightness,
  } from '../store/environment'
  import {
    DEG,
  } from '../lib/units'

  let starsPoints
  const Stars = createStars().then(s => starsPoints = s)

  $: moonMove = new Tween({ theta: -2 * $moonTransitDegrees })
    .by('2s', { theta: 0 }, 'linear')
    .by('4s', { theta: 2 * $moonTransitDegrees }, 'linear')
    .by('6s', { theta: 0 }, 'linear')
    .by('8s', { theta: -2 * $moonTransitDegrees }, 'linear')
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
    const RA = $overrideRA ?
      MathUtils.lerp(-angleLimit, angleLimit, $eclipseProgress) + $moonAngleCorrection :
      state.theta * DEG
    moonRightAscention.set(RA)
  })

</script>

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
  sunBrightness={$sunBrightness}
  sunPosition={$sunPosition}
/>
{/if}
{#if $planet === 'mars'}
<MarsScene
  visible={$earthVisible}
  mountainsVisible={$mountainsVisible}
  planetRadius={$planetRadius}
  position={[0, -$planetRadius, 0]}
  sunBrightness={$sunBrightness}
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

</T.Group>