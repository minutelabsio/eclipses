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
    BlendFunction
  } from 'postprocessing'
  import { GodraysPass } from 'three-good-godrays'
  import createCorona from '../shaders/corona/Corona'
  import createSky from '../shaders/sky/Sky'

  let sunMaterial
  let sunlight
  let sun
  let moon

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

  const FOV = 5 //26.5
  const METER = 1 / 6378
  const Re = 6378 * 1000 * METER
  const AU = 149597870700 * METER

  const elevation = 2 * DEG

  const sunDistance = 1 * AU
  const sunPosition = [0, Math.sin(elevation) * sunDistance, sunDistance]
  const sunRadius = 109 * Re

  let totalityFactor = 0.9
  const eclipseState = {
    get totalityFactor(){ return totalityFactor },
    set totalityFactor(value){ totalityFactor = value }
  }

  const appSettings = new GUI()
  appSettings.add(eclipseState, 'totalityFactor', 0, 1, 0.01)

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

  $: maxCoronaOpacity = totalityFactor * 0.1

  const expoIn = createExpotentialIn(10)
  const expoOut = createExpotentialOut(10)
  const expoLightIn = createExpotentialIn(1)
  const expoLightOut = createExpotentialOut(1)
  $: moonMove = new Tween({ theta: -0.6, corona: 0, brightness: 1 })
    .by('2s', { theta: 0 }, 'quadOut')
    .by('2s', { brightness: 0.1 }, expoLightIn)
    .by('2s', { corona: maxCoronaOpacity }, expoIn)
    .by('4s', { theta: 0.6 }, 'quadIn')
    .by('4s', { brightness: 1.0 }, expoLightOut)
    .by('4s', { corona: 0 }, expoOut)
    .by('6s', { theta: 0 }, 'quadOut')
    .by('6s', { brightness: 0.1 }, expoLightIn)
    .by('6s', { corona: maxCoronaOpacity }, expoIn)
    .by('8s', { theta: -0.6 }, 'quadIn')
    .by('8s', { brightness: 1.0 }, expoLightOut)
    .by('8s', { corona: 0 }, expoOut)
    .loop()

  let time = 0
  useFrame((ctx, dt) => {
    // frame
    time += dt * 1000
    const state = moonMove.at(time / 2)
    moonX = Math.sin(state.theta * DEG) * moonDistance
    sunMaterial.emissiveIntensity = state.brightness
    sunBrightness = state.brightness
    Sky.opacity = state.brightness
    Corona.uniforms.uOpacity.value = state.corona
    Corona.uniforms.uOpacity.needsUpdate = true
  })

  const composer = new EffectComposer(renderer)
  const setupEffectComposer = (camera, sun, sunlight) => {
    if (!camera || !sun || !sunlight) return
    sun.layers.enable(11)
    composer.removeAllPasses()
    const renderpass = new RenderPass(scene, camera)
    renderpass.renderToScreen = false
    composer.addPass(renderpass)
    // const godrays = new GodraysPass(sunlight, camera)
    // godrays.renderToScreen = true
    // composer.addPass(godrays)
    const godrays = new GodRaysEffect(camera, sun, {
      // resolutionScale: 1,
      density: 0.85,
      decay: 0.9,
      weight: 0.2,
      exposure: 0.6,
      samples: 60,
      clampMax: 1.0
    })
    godrays.dithering = true

    const bloom = new SelectiveBloomEffect(scene, camera, {
      intensity: 3,
      height: 512,
      width: 512,
      // luminanceSmoothing: 0.06,
      mipmapBlur: true,
      kernelSize: KernelSize.MEDIUM
    })
    bloom.dithering = true

    composer.addPass(
      new EffectPass(
        camera,
        godrays,
        bloom,
        new SMAAEffect({
          preset: SMAAPreset.ULTRA,
          edgeDetectionMode: EdgeDetectionMode.LUMA,
          // blendFunction: BlendFunction.NORMAL
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
  intensity={sunBrightness * 0.5}
  position={[0, 50, 0]}
/>
<T.Mesh>
  <T.SphereGeometry args={[1000, 32, 15]} />
  <T is={Sky.shader} />
</T.Mesh>

<T.PerspectiveCamera
  position={[0, 1, -1]}
  fov={FOV}
  near={1}
  far={10 * AU}
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
  intensity={0.3*sunIntensity}
  color="white"
  bind:ref={sunlight}
  shadow.camera.near={0.1 * AU}
  shadow.camera.far={1.2 * AU}
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
  <T.MeshBasicMaterial color="#fdffde" bind:ref={sunMaterial} />
</T.Mesh>

<T.Mesh
  position={[sunPosition[0], sunPosition[1], sunPosition[2]]}
  rotation.y={Math.PI}
  scale={[sunRadius, sunRadius, sunRadius]}
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
  <T.MeshStandardMaterial color='#aa8888' dithering/>
</T.Mesh>

<!-- Grid -->
<!-- <Grid
  cellColor="red"
  sectionColor="white"
/> -->