<script>
  import { MathUtils } from 'three'
  import { Easing, Tween } from 'intween'
  import Stats from '../components/Stats.svelte'
  import { T, useThrelte, useFrame } from '@threlte/core'
  import Sky from '../entities/Sky.svelte'
  import Renderer from '../components/Renderer.svelte'
  import DebugControls from '../components/DebugControls.svelte'
  import { eclipseProgress, elevation, totalityFactor, doAnimation, moonRightAscention } from '../store/environment'
  import {
    DEG,
    METER,
    AU,
  } from '../lib/units'

  const { size } = useThrelte()

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
</script>

<DebugControls />
<Renderer/>
<Stats />

<T.OrthographicCamera args={[-$size.width / 2, $size.width / 2, $size.height / 2, -$size.height / 2, 1, 10]} />

<!-- Sky -->
<Sky fisheye={true}/>