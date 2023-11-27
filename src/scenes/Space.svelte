<script>
  import { useThrelte, useRender, useFrame } from '@threlte/core'
  import { Easing, Tween } from 'intween'
  import { OrbitControls, Grid } from '@threlte/extras'
  import Stats from '../components/Stats.svelte'
  import { scalePow } from 'd3-scale'
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
    ToneMappingEffect,
    ToneMappingMode,
    ColorAverageEffect,
  } from 'postprocessing'
  import { CameraRig, FreeMovementControls } from 'three-story-controls'
  import createCorona from '../shaders/corona/Corona'
  import createSky from '../shaders/sky/Sky'
  import createStars from '../shaders/stars/Stars'
  import Earth from '../entities/Earth.svelte'
  import { onMount } from 'svelte'

  const { scene, renderer, camera, size } = useThrelte()

  const skyPosition = (distance, elevation, declination, into = []) => {
    const p = [
      distance * Math.cos(elevation) * Math.sin(declination),
      distance * Math.sin(elevation),
      distance * Math.cos(elevation) * Math.cos(declination)
    ]
    if (into instanceof THREE.Vector3){
      into.set(...p)
      return into
    }
    return p
  }

  let sunMaterial
  let sunlight
  let sun
  let moon
  let corona
  let bloom
  let skyMesh
  let rig
  let controls

  const Corona = createCorona({
    opacity: 0.5
  })

  const Sky = createSky()

  let starsPoints
  const Stars = createStars().then(s => starsPoints = s)

  const DEG = Math.PI / 180

  const WATTS = 1e-3
  const Lsol = 3.828e26 * WATTS
  // luminocity of earth
  const Learth = 1.74e17 * WATTS
  const Isol = 128e3 / 4 / Math.PI

  let FOV = 26.5
  const METER = 1
  const Re = 6378 * 1000 * METER
  const AU = 149597870700 * METER
  const moonOrbitInclination = 5.145 * DEG + 23.44 * DEG
  const moonAxis = new Vector3(1, 0, 0).applyAxisAngle(new Vector3(0, 0, 1), moonOrbitInclination)

  let elevation = 2 * DEG

  const sunDistance = 1 * AU
  const sunRadius = 109 * Re
  let moonRadius = 0.2727 * Re

  let planetRadius = Re
  let altitudeFactor = 0.0
  let atmosphereThickness = Sky.atmosphereThickness

  let exposure = 1
  let totalityFactor = 0.9
  let moonPerigee = 356500 * 1000 * METER
  let moonApogee = 406700 * 1000 * METER
  let lockApparentSize = false
  $: moonDistance = MathUtils.lerp(moonPerigee, moonApogee, 1 - totalityFactor)

  const lookAtSun = () => {
    rig.camera.lookAt(sun.position)
  }

  const lookAtEarth = () => {
    rig.camera.lookAt(new Vector3(0, -planetRadius, 0))
  }

  const eclipseState = {
    get FOV(){ return FOV },
    set FOV(v){ return FOV = v },
    get exposure(){ return exposure },
    set exposure(v){
      exposure = v
    },
    get totalityFactor(){ return totalityFactor },
    set totalityFactor(value){ totalityFactor = value },
    doAnimation: true,
    progress: 0,
    get lockApparentSize(){ return lockApparentSize },
    set lockApparentSize(v){ return lockApparentSize = v },
    get moonRadius(){ return moonRadius },
    set moonRadius(v){ return moonRadius = v },
    get moonPerigee(){ return moonPerigee },
    set moonPerigee(v){ return moonPerigee = v },
    get moonApogee(){ return moonApogee },
    set moonApogee(v){ return moonApogee = v },
    get elevation(){ return elevation / DEG },
    set elevation(value){ elevation = value * DEG },
    get altitude(){ return altitudeFactor },
    set altitude(v){ return altitudeFactor = v },
    get sunIntensity(){ return Sky.sunIntensity },
    set sunIntensity(v){ return Sky.sunIntensity = v },
    get planetRadius(){ return planetRadius },
    set planetRadius(v){ return planetRadius = v },
    get atmosphereThickness(){ return atmosphereThickness },
    set atmosphereThickness(v){ return atmosphereThickness = v },
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
    get iSteps(){ return Sky.iSteps },
    set iSteps(v){ return Sky.iSteps = v },
    get jSteps(){ return Sky.jSteps },
    set jSteps(v){ return Sky.jSteps = v },
    lookAtSun: lookAtSun,
    lookAtEarth: lookAtEarth,
  }

  $: Sky.atmosphereThickness = atmosphereThickness
  // $: {
  //   Sky.exposure = exposure
  //   if (starsPoints){
  //     starsPoints.material.uniforms.exposure.value = exposure
  //     starsPoints.material.uniforms.exposure.needsUpdate = true
  //   }
  // }
  $: renderer.toneMappingExposure = exposure

  const apparentSize = (r, d) => {
    return 2 * Math.asin(r / d) * DEG
  }

  let lastApparentSize = apparentSize(moonRadius, moonPerigee)

  onMount(() => {
    const appSettings = new GUI({
      width: 400
    })
    const perspectiveSettings = appSettings.addFolder('Perspective')
    perspectiveSettings.add(eclipseState, 'FOV', 1, 180, 1)
    perspectiveSettings.add(eclipseState, 'exposure', 0.01, 10, 0.01)
    perspectiveSettings.add(eclipseState, 'altitude', 0, 1, 0.01)
    perspectiveSettings.add(eclipseState, 'lookAtSun')
    perspectiveSettings.add(eclipseState, 'lookAtEarth')
    const eclipseSettings = appSettings.addFolder('Eclipse')
    eclipseSettings.add(eclipseState, 'doAnimation')
    eclipseSettings.add(eclipseState, 'progress', 0, 1, 0.01)
    eclipseSettings.add(eclipseState, 'totalityFactor', 0, 1, 0.01)
    eclipseSettings.add(eclipseState, 'elevation', -90, 90, 0.001)
    const planetSettings = appSettings.addFolder('Planetary')
    planetSettings.add(eclipseState, 'sunIntensity', 0, 500, 1)
    planetSettings.add(eclipseState, 'planetRadius', 1e6, 1e7, 100)
    planetSettings.add(eclipseState, 'lockApparentSize').onChange(v => {
      if (v){
        lastApparentSize = apparentSize(moonRadius, moonPerigee)
      }
    }).name('Lock Size at Perigee')
    const moonRadiusCtrl = planetSettings.add(eclipseState, 'moonRadius', 1e5, 1e7, 100)
    const moonPerigeeCtrl = planetSettings.add(eclipseState, 'moonPerigee', 1e6, 1e9, 100)
    planetSettings.add(eclipseState, 'moonApogee', 1e7, 1e9, 100)
    const atmosSettings = appSettings.addFolder('Atmosphere')
    atmosSettings.add(eclipseState, 'atmosphereThickness', 0, 1000000, 1)
    const rayleighSettings = atmosSettings.addFolder('Rayleigh')
    rayleighSettings.add(eclipseState, 'rayleighRed', 0, 1e-4, 1e-7)
    rayleighSettings.add(eclipseState, 'rayleighGreen', 0, 1e-4, 1e-7)
    rayleighSettings.add(eclipseState, 'rayleighBlue', 0, 1e-4, 1e-7)
    rayleighSettings.add(eclipseState, 'rayleighScaleHeight', 0, 100000, 10)
    const mieSettings = atmosSettings.addFolder('Mie')
    mieSettings.add(eclipseState, 'mieCoefficient', 0, 1e-4, 1e-7)
    mieSettings.add(eclipseState, 'mieScaleHeight', 0, 10000, 10)
    mieSettings.add(eclipseState, 'mieDirectional', -.999, .999, 0.01)
    const precisionSettings = atmosSettings.addFolder('Precision').close()
    precisionSettings.add(eclipseState, 'iSteps', 1, 32, 1)
    precisionSettings.add(eclipseState, 'jSteps', 1, 32, 1)

    moonRadiusCtrl.onChange(r => {
      if (lockApparentSize){
        moonPerigee = (r / Math.sin(lastApparentSize / 2 / DEG))
        moonPerigeeCtrl.updateDisplay()
      }
    })

    moonPerigeeCtrl.onChange(d => {
      if (lockApparentSize){
        moonRadius = d * Math.sin(lastApparentSize / 2 / DEG)
        moonRadiusCtrl.updateDisplay()
      }
    })

    return () => {
      appSettings.destroy()
    }
  })

  const setAltitude = (f, Rp) => {
    const alt = (5 * Math.pow(Rp, f) - 1)
    Sky.altitude = alt
    if (rig){
      let { position, quaternion } = rig.getWorldCoordinates()
      position.y = alt
      rig.setWorldCoordinates({ position, quaternion })
    }
    return alt
  }

  $: setAltitude(altitudeFactor, planetRadius)
  $: Sky.planetRadius = planetRadius
  $: sunPosition = skyPosition(sunDistance, elevation, 0)

  let moonDec = 0

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
  $: moonMove = new Tween({ theta: -0.8, corona: minCoronaOpacity, brightness: 1 })
    .by('2s', { theta: 0 }, 'quadOut')
    .by('2s', { brightness: 0.1 }, expoLightIn)
    .by('2s', { corona: maxCoronaOpacity }, expoIn)
    .by('4s', { theta: 0.8 }, 'quadIn')
    .by('4s', { brightness: 1.0 }, expoLightOut)
    .by('4s', { corona: minCoronaOpacity }, expoOut)
    .by('6s', { theta: 0 }, 'quadOut')
    .by('6s', { brightness: 0.1 }, expoLightIn)
    .by('6s', { corona: maxCoronaOpacity }, expoIn)
    .by('8s', { theta: -0.8 }, 'quadIn')
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
    controls?.update(window.performance.now())
    const state = moonMove.at(time / 2)
    moonDec = state.theta * DEG
  })

  $: r0 = new Vector3(0, -planetRadius, 0)
  $: Sky.sunPosition.set(...sunPosition).sub(r0).multiplyScalar(1 / METER)
  $: Sky.sunRadius = sunRadius / METER
  $: moonPosition = skyPosition(moonDistance, elevation, 0, new Vector3()).applyAxisAngle(moonAxis, moonDec)
  $: Sky.moonPosition.set(...moonPosition).sub(r0).multiplyScalar(1 / METER)
  $: Sky.moonRadius = moonRadius / METER

  const composer = new EffectComposer(renderer, {
    frameBufferType: THREE.HalfFloatType,
    multisampling: 0
  })

  const setupEffectComposer = async (camera, { sun, sunlight, skyMesh }) => {
    const stars = await Stars
    if (!camera || !sun || !sunlight || !stars) return
    // stars.layers.enable(11)
    // skyMesh.layers.enable(11)
    // sun.layers.enable(11)
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
      blendFunction: BlendFunction.ADD,
      density: 0.85,
      decay: 0.95,
      weight: 0.8,
      exposure: 0.9,
      samples: 60,
      clampMax: 1
    })
    godrays.dithering = true

    bloom = new SelectiveBloomEffect(scene, camera, {
      intensity: 10,
      luminanceThreshold: 0.5,
      luminanceSmoothing: .5,
      blendFunction: BlendFunction.ADD,
      radius: .9, //.99,
      levels: 10, //40,
      mipmapBlur: true
    })
    bloom.dithering = true
    // bloom.ignoreBackground = true
    // bloom.inverted = true

    // composer.addPass(goodrays)

    composer.addPass(
      new EffectPass(
        camera,
        new SMAAEffect({
          preset: SMAAPreset.HIGH,
          edgeDetectionMode: EdgeDetectionMode.LUMA,
          // edgeDetectionMode: EdgeDetectionMode.DEPTH,
          blendFunction: BlendFunction.SCREEN
        }),
        bloom,
        // godrays,
        new ToneMappingEffect({
          // blendFunction: BlendFunction.NORMAL,
          // mode: ToneMappingMode.ACES_FILMIC,
          // mode: ToneMappingMode.REINHARD2,
          mode: ToneMappingMode.REINHARD2_ADAPTIVE,
          // adaptive: true,
          // resolution: 256,
          // middleGrey: 0.6,
          resolution: 512,
          whitePoint: 4,
          minLuminance: 0.01,
          averageLuminance: .1,
          adaptationRate: 2
        }),
      )
    )
  }
  // We need to set up the passes according to the camera in use
  $: composer.setSize($size.width, $size.height)
  $: setupEffectComposer($camera, { sun, sunlight, skyMesh })
  useRender((_, delta) => {
    composer.render(delta)
  })
</script>

<Stats />

<T.AmbientLight intensity={0.0001}/>
<!-- <Sky elevation={0.1} /> -->
<!-- <T.HemisphereLight
  intensity={sunBrightness * 0.2}
  position={[0, 50, 0]}
/> -->
{#await Stars then Stars}
<T is={Stars} />
{/await}

<T.Mesh
  bind:ref={skyMesh}
  scale={[AU, AU, AU]}
>
  <T.IcosahedronGeometry args={[1, 16]} />
  <T is={Sky.shader} />
</T.Mesh>

<T.PerspectiveCamera
  position.z={-2}
  fov={FOV}
  near={1}
  far={1.2 * sunDistance}
  makeDefault
  on:create={({ ref }) => {
    ref.lookAt(sun.position)
    rig = new CameraRig(ref, scene)
    controls = new FreeMovementControls(rig, {
      domElement: renderer.domElement.parentNode,
      tiltDegreeFactor: Math.PI / 6,
      panDegreeFactor: Math.PI / 6,
    })
    controls.enable()
  }}
  on:destroy={() => {
    controls.disable()
  }}
>
  <!-- <OrbitControls
    enableZoom={true}
    maxPolarAngle={170 * DEG}
    enableDamping
    target.y={altitude}
  /> -->
</T.PerspectiveCamera>

<!-- Sun -->
<T.PointLight
  position={sunPosition}
  intensity={5e14 * sunIntensity}
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
  visible={false}
  position={sunPosition}
  bind:ref={sun}
>
  <T.SphereGeometry args={[sunRadius, 32, 32]} />
  <T.MeshStandardMaterial emissive="#fdffde" bind:ref={sunMaterial} emissiveIntensity={16} />
</T.Mesh>

<!-- Corona -->
<T.Mesh
  visible={false}
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
  visible={false}
  bind:ref={moon}
  position={moonPosition.toArray()}
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
<!-- <T.Mesh
  position={[0, -planetRadius, 0]}
  rotation={[0, 0, 0]}
  receiveShadow
>
  <T.IcosahedronGeometry args={[planetRadius+1, 256]} />
  <T.MeshStandardMaterial color='#888' dithering/>
</T.Mesh> -->
<Earth planetRadius={planetRadius} position={[0, -planetRadius, 0]} />
