<script>
  import { useThrelte, useRender, useFrame } from '@threlte/core'
  import { Easing, Tween } from 'intween'
  import { OrbitControls, Grid } from '@threlte/extras'
  import { T } from '@threlte/core'
  import * as THREE from 'three'
  import GUI from 'lil-gui'
  import { PlaneGeometry, SphereGeometry, Vector3, MathUtils, Mesh, HemisphereLight } from 'three'
  import {
    EffectComposer,
    EffectPass,
    RenderPass,
    SMAAEffect,
    SMAAPreset,
    SelectiveBloomEffect,
    GodRaysEffect,
    KernelSize,
    EdgeDetectionMode,
    PredicationMode,
    BlendMode,
    BlendFunction,

    GammaCorrectionEffect,

    ChromaticAberrationEffect


  } from 'postprocessing'
  import { GodraysPass } from 'three-good-godrays'
  import createCorona from '../shaders/corona/Corona'
  import createSky from '../shaders/sky/Sky'

  let sunMaterial
  let sunlight
  let sun
  let moon
  let corona
  let bloom

  const Corona = createCorona({
    opacity: 0.5
  })

  const Sky = createSky()

  const DEG = Math.PI / 180
  const { scene, renderer, camera, size } = useThrelte()

  const WATTS = 1e-3
  const Lsol = 3.828e26 * WATTS
  // luminocity of earth
  const Learth = 1.74e17 * WATTS
  const Isol = 128e3 / 4 / Math.PI

  const FOV = 26.5
  const METER = 1 / 6378
  const Re = 6378 * 1000 * METER
  const AU = 149597870700 * METER

  let elevation = 2 * DEG

  const sunDistance = 1 * AU
  $: sunPosition = [0, Math.sin(elevation) * sunDistance, sunDistance]
  const sunRadius = 109 * Re

  let totalityFactor = 0.9

  const eclipseState = {
    get totalityFactor(){ return totalityFactor },
    set totalityFactor(value){ totalityFactor = value },
    get elevation(){ return elevation / DEG },
    set elevation(value){ elevation = value * DEG },
    doAnimation: true,
    progress: 0,
    get altitude(){ return Sky.altitude },
    set altitude(v){ return Sky.altitude = v },
    get sunIntensity(){ return Sky.sunIntensity },
    set sunIntensity(v){ return Sky.sunIntensity = v },
    get planetRadius(){ return Sky.planetRadius },
    set planetRadius(v){ return Sky.planetRadius = v },
    get atmosphereThickness(){ return Sky.atmosphereThickness },
    set atmosphereThickness(v){ return Sky.atmosphereThickness = v },
    get rayleighRed(){ return Sky.rayleighCoefficients.x },
    set rayleighRed(v){ return Sky.rayleighCoefficients.x = v },
    get rayleighGreen(){ return Sky.rayleighCoefficients.y },
    set rayleighGreen(v){ return Sky.rayleighCoefficients.y = v },
    get rayleighBlue(){ return Sky.rayleighCoefficients.z },
    set rayleighBlue(v){ return Sky.rayleighCoefficients.z = v },
    get rayleighScaleHeight(){ return Sky.rayleighScaleHeight },
    set rayleighScaleHeight(v){ return Sky.rayleighScaleHeight = v },
    get mieCoefficient(){ return Sky.mieCoefficient },
    set mieCoefficient(v){ return Sky.mieCoefficient = v },
    get mieScaleHeight(){ return Sky.mieScaleHeight },
    set mieScaleHeight(v){ return Sky.mieScaleHeight = v },
    get mieDirectional(){ return Sky.mieDirectional },
    set mieDirectional(v){ return Sky.mieDirectional = v },
  }

  const appSettings = new GUI({
    width: 400
  })
  appSettings.add(eclipseState, 'totalityFactor', 0, 1, 0.01)
  appSettings.add(eclipseState, 'elevation', 0, 30, 0.01)
  appSettings.add(eclipseState, 'doAnimation')
  appSettings.add(eclipseState, 'progress', 0, 1, 0.01)
  const skySettings = appSettings.addFolder('Sky')
  skySettings.add(eclipseState, 'altitude', 0, 100000, 1)
  skySettings.add(eclipseState, 'sunIntensity', 0, 50, 1)
  skySettings.add(eclipseState, 'planetRadius', 1, 1e8, 100)
  skySettings.add(eclipseState, 'atmosphereThickness', 0, 1000000, 1)
  const rayleighSettings = skySettings.addFolder('Rayleigh')
  rayleighSettings.add(eclipseState, 'rayleighRed', 0, 1e-4, 1e-7)
  rayleighSettings.add(eclipseState, 'rayleighGreen', 0, 1e-4, 1e-7)
  rayleighSettings.add(eclipseState, 'rayleighBlue', 0, 1e-4, 1e-7)
  rayleighSettings.add(eclipseState, 'rayleighScaleHeight', 0, 100000, 10)
  const mieSettings = skySettings.addFolder('Mie')
  mieSettings.add(eclipseState, 'mieCoefficient', 0, 1e-4, 1e-7)
  mieSettings.add(eclipseState, 'mieScaleHeight', 0, 10000, 10)
  mieSettings.add(eclipseState, 'mieDirectional', 0, 1, 0.01)

  const moonPerigee = 356500 * 1000 * METER
  const moonApogee = 406700 * 1000 * METER
  let moonX = 0
  $: moonDistance = MathUtils.lerp(moonPerigee, moonApogee, 1 - totalityFactor)
  $: moonPosition = [moonX, Math.sin(elevation) * moonDistance, moonDistance]
  const moonRadius = 0.2727 * Re

  const orbitTarget =  [0, 1.02, 0]
  let sunBrightness = 1
  $: sunIntensity = sunBrightness * 10000000 * Lsol / (4 * Math.PI * Math.pow(sunDistance, 2))

  const createExpotentialIn = (a) => {
    return (x) => Math.pow(2, a * x - a) * x
  }

  const createExpotentialOut = (a) => {
    return (x) => 1 - Math.pow(2, -a * x) * (1 - x)
  }

  $: maxCoronaOpacity = totalityFactor * 0.09
  let minCoronaOpacity = 0.06

  const expoIn = createExpotentialIn(10)
  const expoOut = createExpotentialOut(10)
  const expoLightIn = createExpotentialIn(1)
  const expoLightOut = createExpotentialOut(1)
  $: moonMove = new Tween({ theta: -0.6, corona: minCoronaOpacity, brightness: 1 })
    .by('2s', { theta: 0 }, 'quadOut')
    .by('2s', { brightness: 0.1 }, expoLightIn)
    .by('2s', { corona: maxCoronaOpacity }, expoIn)
    .by('4s', { theta: 0.6 }, 'quadIn')
    .by('4s', { brightness: 1.0 }, expoLightOut)
    .by('4s', { corona: minCoronaOpacity }, expoOut)
    .by('6s', { theta: 0 }, 'quadOut')
    .by('6s', { brightness: 0.1 }, expoLightIn)
    .by('6s', { corona: maxCoronaOpacity }, expoIn)
    .by('8s', { theta: -0.6 }, 'quadIn')
    .by('8s', { brightness: 1.0 }, expoLightOut)
    .by('8s', { corona: minCoronaOpacity }, expoOut)
    .loop()

  let time = 0
  useFrame((ctx, dt) => {
    // frame
    if (eclipseState.doAnimation) {
      time += dt * 1000
    } else {
      time = eclipseState.progress * moonMove.duration
    }
    const state = moonMove.at(time / 2)
    moonX = Math.sin(state.theta * DEG) * moonDistance
    // sunMaterial.emissiveIntensity = state.brightness
    sunBrightness = state.brightness
    bloom.intensity = 0.0009 * (30 * (1 - Math.sqrt(state.brightness)) + 5)
    Sky.opacity = state.brightness
    Corona.uniforms.uOpacity.value = state.corona
    Corona.uniforms.uOpacity.needsUpdate = true
    Sky.moonPosition.set(moonX, Math.sin(elevation) * moonDistance, moonDistance).multiplyScalar(1 / METER)
  })

  $: Sky.sunPosition.set(...sunPosition).multiplyScalar(1 / METER)
  $: Sky.sunRadius = sunRadius / METER
  $: Sky.moonRadius = moonRadius / METER

  const composer = new EffectComposer(renderer, {
    frameBufferType: THREE.HalfFloatType,
  })

  const setupEffectComposer = (camera, sun, sunlight) => {
    if (!camera || !sun || !sunlight) return
    sun.layers.enable(11)
    // corona.layers.enable(11)
    composer.removeAllPasses()
    const renderpass = new RenderPass(scene, camera)
    renderpass.renderToScreen = false
    composer.addPass(renderpass)
    // const goodrays = new GodraysPass(sunlight, camera)
    // goodrays.renderToScreen = false
    // composer.addPass(goodrays)
    const godrays = new GodRaysEffect(camera, sun, {
      resolutionScale: 1,
      density: 0.95,
      decay: 0.9,
      weight: 0.2,
      exposure: 0.9,
      samples: 60,
      clampMax: 1
    })
    godrays.dithering = true

    bloom = new SelectiveBloomEffect(scene, camera, {
      intensity: 30,
      luminanceThreshold: 0.5,
      luminanceSmoothing: 0.4,
      blendFunction: BlendFunction.SCREEN,
      radius: .9,
      // levels: 10,
      mipmapBlur: true
    })
    bloom.dithering = true
    // bloom.inverted = true

    // composer.addPass(goodrays)

    composer.addPass(
      new EffectPass(
        camera,
        bloom,
        // godrays,
        new SMAAEffect({
          preset: SMAAPreset.HIGH,
          // edgeDetectionMode: EdgeDetectionMode.LUMA,
          edgeDetectionMode: EdgeDetectionMode.DEPTH,
          blendFunction: BlendFunction.SCREEN
        })
      )
    )
  }
  // We need to set up the passes according to the camera in use
  $: composer.setSize($size.width, $size.height)
  $: setupEffectComposer($camera, sun, sunlight)
  useRender((_, delta) => {
    composer.render(delta)
  })
</script>

<!-- <T.AmbientLight intensity={0.1}/> -->
<!-- <Sky elevation={0.1} /> -->
<T.HemisphereLight
  intensity={sunBrightness * 0.2}
  position={[0, 50, 0]}
/>
<T.Mesh>
  <T.SphereGeometry args={[moonDistance - 100, 32, 15]} />
  <T is={Sky.shader} />
</T.Mesh>

<T.PerspectiveCamera
  position={[0, 1, -1]}
  fov={FOV}
  near={1}
  far={1.2 * sunDistance}
  makeDefault
  on:create={({ ref }) => {
    // ref.lookAt(0, 0, 10)
  }}
>
  <OrbitControls
    enableZoom={true}
    maxPolarAngle={170 * DEG}
    enableDamping
    target={orbitTarget}
  />
</T.PerspectiveCamera>


<!-- Sun -->
<T.PointLight
  position={sunPosition}
  intensity={sunIntensity}
  color="white"
  bind:ref={sunlight}
  shadow.camera.near={0.8 * sunDistance}
  shadow.camera.far={1.2 * sunDistance}
  shadow.mapSize.width={1024}
  shadow.mapSize.height={1024}
  shadow.autoUpdate={true}
  castShadow
/>
<T.Mesh
  position={sunPosition}
  bind:ref={sun}
>
  <T.SphereGeometry args={[sunRadius, 32, 32]} />
  <T.MeshStandardMaterial emissive="#fdffde" bind:ref={sunMaterial} emissiveIntensity={Isol} />
</T.Mesh>

<!-- Corona -->
<T.Mesh
  position={[sunPosition[0], sunPosition[1], sunPosition[2]]}
  rotation.y={Math.PI}
  scale={[sunRadius, sunRadius, sunRadius]}
  bind:ref={corona}
>
  <T.PlaneGeometry args={[4.4, 4.32]} />
  <T is={Corona}/>
</T.Mesh>

<!-- moon -->
<T.Mesh
  bind:ref={moon}
  position={moonPosition}
  rotation={[180 * DEG, 0, 0]}
  castShadow
  receiveShadow
>
  <!-- <T.SphereGeometry args={[moonRadius, 32, 32]} /> -->
  <T.IcosahedronGeometry args={[moonRadius, 32]} />
  <!-- <T.CircleGeometry args={[moonRadius, 32]} /> -->
  <T.MeshBasicMaterial color="black" dithering />
</T.Mesh>

<!-- Ground -->
<T.Mesh
  position={[0, -0.1, 0]}
  rotation={[-90 * DEG, 0, 0]}
  receiveShadow
>
  <T.PlaneGeometry args={[1000, 1000]} />
  <T.MeshStandardMaterial color='#998888' dithering/>
</T.Mesh>

<!-- Grid -->
<!-- <Grid
  cellColor="red"
  sectionColor="white"
/> -->