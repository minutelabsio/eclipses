<script>
  import { useThrelte, useFrame } from '@threlte/core'
  import { Easing, Tween } from 'intween'
  import Stats from '../components/Stats.svelte'
  import { T } from '@threlte/core'
  import GUI from 'lil-gui'
  import { Vector3, MathUtils } from 'three'
  import createCorona from '../shaders/corona/Corona'
  import createSky from '../shaders/sky/Sky'
  import createStars from '../shaders/stars/Stars'
  import Earth from '../entities/Earth.svelte'
  import Jupiter from '../entities/Jupiter.svelte'
  import { onMount } from 'svelte'
  import Renderer from '../components/Renderer.svelte'
  import Camera from '../components/Camera.svelte'

  import {
    planetRadius,
    atmosphereThickness,
    elevationRad,
    totalityFactor,
    sunIntensity,
    sunPosition,
    sunRadius,
    moonRadius,
    moonPerigee,
    moonRightAscention,
    moonPosition,
    moonDistance,
    rayleighRed,
    rayleighGreen,
    rayleighBlue,
    rayleighScaleHeight,
    mieCoefficient,
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
    windSpeed,
    getDatGuiState,
    starsVisible,
    skyVisible,
    mountainsVisible,
    earthVisible,
    altitude,
    elevation,
  } from '../store/environment'
  import {
    DEG,
    METER,
    AU,
  } from '../lib/units'
  import { skyPosition } from '../lib/sky-position'

  const { scene, renderer, autoRender } = useThrelte()

  let sunMaterial
  let sunlight
  let sun
  let moon
  let corona
  let skyMesh
  let controls

  const Corona = createCorona({
    opacity: 0.5
  })

  const Sky = createSky()

  let starsPoints
  const Stars = createStars().then(s => starsPoints = s)

  const lookAtSun = () => {
    const [x, y, z] = $sunPosition
    controls.lookInDirectionOf(x, y, z, true)
  }

  const lookAtEarth = () => {
    controls.lookInDirectionOf(0, -$planetRadius, 0, true)
  }

  const eclipseState = {
    doAnimation: false,
    progress: 0,
    lockApparentSize: false,
    // scale factor
    altitude: Math.log(($altitude + 1) / 5) / Math.log($planetRadius),

    lookAtSun: lookAtSun,
    lookAtEarth: lookAtEarth,
  }

  const apparentSize = (r, d) => {
    return 2 * Math.asin(r / d) * DEG
  }

  let lastApparentSize = apparentSize($moonRadius, $moonPerigee)

  const setAltitude = (f, Rp) => {
    const alt = (5 * Math.pow(Rp, f) - 1)
    altitude.set(alt)
  }

  onMount(() => {
    const state = getDatGuiState()
    const appSettings = new GUI({
      width: 400
    })
    const perspectiveSettings = appSettings.addFolder('Perspective')
    perspectiveSettings.add(state, 'FOV', 1, 180, 1)
    perspectiveSettings.add(state, 'exposure', 0.01, 10, 0.01)
    perspectiveSettings.add(state, 'bloomIntensity', 0, 50, 0.01)
    perspectiveSettings.add(eclipseState, 'altitude', 0.2, 1, 0.01).onChange(v => {
      setAltitude(v, $planetRadius)
    })
    perspectiveSettings.add(eclipseState, 'lookAtSun')
    perspectiveSettings.add(eclipseState, 'lookAtEarth')

    const eclipseSettings = appSettings.addFolder('Eclipse')
    eclipseSettings.add(eclipseState, 'doAnimation')
    eclipseSettings.add(eclipseState, 'progress', 0, 1, 0.01)
    eclipseSettings.add(state, 'totalityFactor', 0, 1, 0.01)
    eclipseSettings.add(state, 'elevation', -90, 90, 0.001)

    const planetSettings = appSettings.addFolder('Planetary')
    planetSettings.add(state, 'sunIntensity', 0, 500, 1)
    planetSettings.add(state, 'planetRadius', 1e6, 1e7, 100)
    planetSettings.add(eclipseState, 'lockApparentSize').onChange(v => {
      if (v){
        lastApparentSize = apparentSize($moonRadius, $moonPerigee)
      }
    }).name('Lock Size at Perigee')
    const moonRadiusCtrl = planetSettings.add(state, 'moonRadius', 1e5, 1e7, 100)
    const moonPerigeeCtrl = planetSettings.add(state, 'moonPerigee', 1e6, 1e9, 100)
    planetSettings.add(state, 'moonApogee', 1e7, 1e9, 100)

    const atmosSettings = appSettings.addFolder('Atmosphere')
    atmosSettings.add(state, 'atmosphereThickness', 0, 1000000, 1)

    const rayleighSettings = atmosSettings.addFolder('Rayleigh')
    rayleighSettings.add(state, 'rayleighRed', 0, 1e-4, 1e-7)
    rayleighSettings.add(state, 'rayleighGreen', 0, 1e-4, 1e-7)
    rayleighSettings.add(state, 'rayleighBlue', 0, 1e-4, 1e-7)
    rayleighSettings.add(state, 'rayleighScaleHeight', 0, 100000, 10)

    const mieSettings = atmosSettings.addFolder('Mie')
    mieSettings.add(state, 'mieCoefficient', 0, 1e-4, 1e-7)
    mieSettings.add(state, 'mieScaleHeight', 0, 10000, 10)
    mieSettings.add(state, 'mieDirectional', -.999, .999, 0.01)

    const cloudSettings = atmosSettings.addFolder('Clouds')
    cloudSettings.add(state, 'cloudZ', 0.01, 0.9, 0.01)
    cloudSettings.add(state, 'cloudThickness', 0, 20, 0.1)
    cloudSettings.add(state, 'cloudSize', 0, 10, 0.1)
    cloudSettings.add(state, 'cloudMie', 0, .999, 1e-7)
    cloudSettings.add(state, 'cloudThreshold', 0, 1, 0.01)
    cloudSettings.add(state, 'windSpeed', 0, 1, 0.01)

    const performanceSettings = atmosSettings.addFolder('performance').close()
    performanceSettings.add(state, 'iSteps', 1, 32, 1)
    performanceSettings.add(state, 'jSteps', 1, 32, 1)

    const visibilitySettings = appSettings.addFolder('Visibility').close()
    visibilitySettings.add(state, 'skyVisible')
    visibilitySettings.add(state, 'starsVisible')
    visibilitySettings.add(state, 'mountainsVisible')
    visibilitySettings.add(state, 'earthVisible')

    moonRadiusCtrl.onChange(r => {
      if (eclipseState.lockApparentSize){
        $moonPerigee = (r / Math.sin(lastApparentSize / 2 / DEG))
        moonPerigeeCtrl.updateDisplay()
      }
    })

    moonPerigeeCtrl.onChange(d => {
      if (eclipseState.lockApparentSize){
        $moonRadius = d * Math.sin(lastApparentSize / 2 / DEG)
        moonRadiusCtrl.updateDisplay()
      }
    })

    let auto = autoRender.current
    autoRender.set(false)

    return () => {
      appSettings.destroy()
      autoRender.set(auto)
    }
  })

  let sunBrightness = 1
  $: sunsetBrightness = MathUtils.clamp(MathUtils.inverseLerp(-10, 10, $elevation), 0, 1)

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
    if (eclipseState.doAnimation) {
      time += dt * 1000
    } else {
      time = eclipseState.progress * moonMove.duration
    }
    // controls?.update(window.performance.now())
    const state = moonMove.at(time / 2)
    moonRightAscention.set(state.theta * DEG)
    sunBrightness = state.brightness * sunsetBrightness
  })

  let fog

  $: Sky.sunIntensity = $sunIntensity
  $: Sky.rayleighCoefficients.x = $rayleighRed
  $: Sky.rayleighCoefficients.y = $rayleighGreen
  $: Sky.rayleighCoefficients.z = $rayleighBlue
  $: Sky.rayleighScaleHeight = $rayleighScaleHeight
  $: Sky.mieCoefficient = $mieCoefficient
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
  $: Sky.windSpeed = $windSpeed
  $: Sky.atmosphereThickness = $atmosphereThickness
  // $: Sky.altitude = $altitude
  $: Sky.planetRadius = $planetRadius
  $: Sky.sunPosition.set(...$sunPosition)
  $: Sky.sunRadius = $sunRadius / METER
  $: Sky.moonPosition.copy($moonPosition)
  $: Sky.moonRadius = $moonRadius / METER
  $: fog?.color.setHSL(200 / 360, .2, Easing.sinIn(sunBrightness) * 0.3)
</script>

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
  bind:controls={controls}
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
    position={[$sunPosition[0], $sunPosition[1], $sunPosition[2]]}
    rotation.y={Math.PI}
    scale={[$sunRadius, $sunRadius, $sunRadius]}
    bind:ref={corona}
  >
    <T.PlaneGeometry args={[4.4, 4.32]} />
    <T is={Corona}/>
  </T.Mesh>

  <T.Mesh
    visible={$skyVisible}
    scale.x={$planetRadius + $atmosphereThickness}
    scale.y={$planetRadius + $atmosphereThickness}
    scale.z={$planetRadius + $atmosphereThickness}
    bind:ref={skyMesh}
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