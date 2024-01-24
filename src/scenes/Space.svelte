<script>
  import { useThrelte, useTask, useFrame } from '@threlte/core'
  import { Easing, Tween } from 'intween'
  import Stats from '../components/Stats.svelte'
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
    EdgeDetectionMode,
    BlendFunction,
    ToneMappingEffect,
    ToneMappingMode,
    Selection,
  } from 'postprocessing'
  import { CameraRig, FreeMovementControls } from 'three-story-controls'
  import createCorona from '../shaders/corona/Corona'
  import createSky from '../shaders/sky/Sky'
  import createStars from '../shaders/stars/Stars'
  import Earth from '../entities/Earth.svelte'
  import Jupiter from '../entities/Jupiter.svelte'
  import { onMount } from 'svelte'

  const { scene, renderer, camera, size, autoRender, renderStage } = useThrelte()

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
  let altitudeFactor = 0.001
  let atmosphereThickness = Sky.atmosphereThickness

  let exposure = 1
  let totalityFactor = 0.9
  let moonPerigee = 356500 * 1000 * METER
  let moonApogee = 406700 * 1000 * METER
  let lockApparentSize = false
  $: moonDistance = MathUtils.lerp(moonPerigee, moonApogee, 1 - totalityFactor)

  // visibility
  let skyVisible = true
  let starsVisible = true
  let mountainsVisible = true
  let earthVisible = true

  let bloomIntensity = 5

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
    get bloomIntensity(){ return bloomIntensity },
    set bloomIntensity(v){ return bloomIntensity = v },
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
    // clouds
    get cloudZ(){ return Sky.cloudZ },
    set cloudZ(v){ return Sky.cloudZ = v },
    get cloudThickness(){ return Sky.cloudThickness },
    set cloudThickness(v){ return Sky.cloudThickness = v },
    get cloudSize(){ return Sky.cloudSize },
    set cloudSize(v){ return Sky.cloudSize = v },
    get cloudMie(){ return Sky.cloudMie },
    set cloudMie(v){ return Sky.cloudMie = v },
    get cloudThreshold(){ return Sky.cloudThreshold },
    set cloudThreshold(v){ return Sky.cloudThreshold = v },
    get windSpeed(){ return Sky.windSpeed },
    set windSpeed(v){ return Sky.windSpeed = v },

    get iSteps(){ return Sky.iSteps },
    set iSteps(v){ return Sky.iSteps = v },
    get jSteps(){ return Sky.jSteps },
    set jSteps(v){ return Sky.jSteps = v },

    // visibility
    get skyVisible(){ return skyVisible },
    set skyVisible(v){ return skyVisible = v },
    get starsVisible(){ return starsVisible },
    set starsVisible(v){ return starsVisible = v },
    get mountainsVisible(){ return mountainsVisible },
    set mountainsVisible(v){ return mountainsVisible = v },
    get earthVisible(){ return earthVisible },
    set earthVisible(v){ return earthVisible = v },

    lookAtSun: lookAtSun,
    lookAtEarth: lookAtEarth,
  }

  $: Sky.atmosphereThickness = atmosphereThickness
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
    perspectiveSettings.add(eclipseState, 'bloomIntensity', 0, 50, 0.01)
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

    const cloudSettings = atmosSettings.addFolder('Clouds')
    cloudSettings.add(eclipseState, 'cloudZ', 0.01, 0.9, 0.01)
    cloudSettings.add(eclipseState, 'cloudThickness', 0, 20, 0.1)
    cloudSettings.add(eclipseState, 'cloudSize', 0, 10, 0.1)
    cloudSettings.add(eclipseState, 'cloudMie', 0, .999, 1e-7)
    cloudSettings.add(eclipseState, 'cloudThreshold', 0, 1, 0.01)
    cloudSettings.add(eclipseState, 'windSpeed', 0, 1, 0.01)

    const performanceSettings = atmosSettings.addFolder('performance').close()
    performanceSettings.add(eclipseState, 'iSteps', 1, 32, 1)
    performanceSettings.add(eclipseState, 'jSteps', 1, 32, 1)

    const visibilitySettings = appSettings.addFolder('Visibility').close()
    visibilitySettings.add(eclipseState, 'skyVisible')
    visibilitySettings.add(eclipseState, 'starsVisible')
    visibilitySettings.add(eclipseState, 'mountainsVisible')
    visibilitySettings.add(eclipseState, 'earthVisible')

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

    let auto = autoRender.current
    autoRender.set(false)

    return () => {
      appSettings.destroy()
      autoRender.set(auto)
    }
  })

  const setAltitude = (rig, f, Rp) => {
    const alt = (5 * Math.pow(Rp, f) - 1)
    Sky.altitude = alt
    if (rig){
      let { position, quaternion } = rig.getWorldCoordinates()
      position.y = alt
      rig.setWorldCoordinates({ position, quaternion })
    }
    return alt
  }

  $: setAltitude(rig, altitudeFactor, planetRadius)
  $: Sky.planetRadius = planetRadius
  $: sunPosition = skyPosition(sunDistance, elevation, 0)

  let moonDec = 0

  let sunBrightness = 1
  $: sunIntensity = sunBrightness * 10000000 * Lsol / (4 * Math.PI * Math.pow(sunDistance, 2))
  $: sunsetBrightness = MathUtils.clamp(MathUtils.inverseLerp(-10, 10, elevation / DEG), 0, 1)

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
    controls?.update(window.performance.now())
    const state = moonMove.at(time / 2)
    moonDec = state.theta * DEG
    sunBrightness = state.brightness * sunsetBrightness
  })

  let fog
  $: r0 = new Vector3(0, -planetRadius, 0)
  $: Sky.sunPosition.set(...sunPosition).sub(r0).multiplyScalar(1 / METER)
  $: Sky.sunRadius = sunRadius / METER
  $: moonPosition = skyPosition(moonDistance, elevation, 0, new Vector3()).applyAxisAngle(moonAxis, moonDec)
  $: Sky.moonPosition.set(...moonPosition).sub(r0).multiplyScalar(1 / METER)
  $: Sky.moonRadius = moonRadius / METER
  $: fog?.color.setHSL(200 / 360, .2, Easing.sinIn(sunBrightness) * 0.3)

  const composer = new EffectComposer(renderer, {
    frameBufferType: THREE.HalfFloatType,
    multisampling: 0
  })

  let bloom = {}

  const setupEffectComposer = async (camera) => {
    if (!camera) return
    composer.removeAllPasses()
    const renderpass = new RenderPass(scene, camera)
    renderpass.selection = new Selection([], 0)
    composer.addPass(renderpass)
    const renderpass2 = new RenderPass(scene, camera)
    renderpass2.clear = false
    renderpass2.selection = new Selection([], 9)
    composer.addPass(renderpass2)

    bloom = new SelectiveBloomEffect(scene, camera, {
      intensity: bloomIntensity,
      luminanceThreshold: 1.2, //0.5,
      luminanceSmoothing: 0.7,
      blendFunction: BlendFunction.ADD,
      radius: .8, //.99,
      levels: 10, //40,
      mipmapBlur: true
    })
    bloom.dithering = true
    bloom.inverted = true

    composer.addPass(
      new EffectPass(
        camera,
        bloom,
        // new SMAAEffect({
        //   preset: SMAAPreset.LOW,
        //   edgeDetectionMode: EdgeDetectionMode.LUMA,
        //   // edgeDetectionMode: EdgeDetectionMode.DEPTH,
        //   blendFunction: BlendFunction.SCREEN
        // }),
        new ToneMappingEffect({
          // blendFunction: BlendFunction.NORMAL,
          // mode: ToneMappingMode.ACES_FILMIC,
          // mode: ToneMappingMode.REINHARD2,
          mode: ToneMappingMode.REINHARD2_ADAPTIVE,
          // adaptive: true,
          // resolution: 256,
          // middleGrey: 0.6,
          // resolution: 512,
          whitePoint: 2,
          minLuminance: 0.005,
          adaptationRate: 2
        }),
      )
    )
  }
  // We need to set up the passes according to the camera in use
  $: setupEffectComposer($camera)
  $: composer.setSize($size.width, $size.height)
  $: bloom.intensity = bloomIntensity

  // $: { renderer && (renderer.autoClear = false) }
  useTask((delta) => {
    if (!renderer){ return }
    // renderer.clear()
    // $camera.layers.set(0)
    // renderer.render(scene, $camera)
    // $camera.layers.set(9)
    // renderer.render(scene, $camera)
    // $camera.layers.set(8)
    composer.render(delta)
  }, { stage: renderStage, autoInvalidate: false })
</script>

<Stats />

<!-- <T.AmbientLight intensity={0.02}/> -->
<T.FogExp2 attach="fog" bind:ref={fog} density={1.5e-5} layers={9}/>
<!-- <Sky elevation={0.1} /> -->
<!-- <T.HemisphereLight
  intensity={sunBrightness * 0.2}
  position={[0, 50, 0]}
/> -->
{#await Stars then Stars}
<T is={Stars} renderOrder={0} visible={starsVisible}/>
{/await}

<T.Mesh
  visible={skyVisible}
  bind:ref={skyMesh}
  scale={[AU, AU, AU]}
  renderOrder={2}
>
  <T.IcosahedronGeometry args={[1, 32]} />
  <T is={Sky.shader} />
</T.Mesh>


<T.PerspectiveCamera
  position.z={-2}
  fov={FOV}
  near={1}
  far={1.2 * moonDistance}
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
<!-- <T.PointLight
  position={sunPosition}
  intensity={4e14 * sunIntensity}
  color="white"
/> -->
<T.Mesh
  visible={false}
  position={sunPosition}
  bind:ref={sun}
>
  <T.SphereGeometry args={[sunRadius, 32, 32]} />
  <T.MeshStandardMaterial emissive="#fdffde" bind:ref={sunMaterial} emissiveIntensity={16} />
</T.Mesh>

<!-- Corona -->
<!-- <T.Mesh
  visible={false}
  position={[sunPosition[0], sunPosition[1], sunPosition[2]]}
  rotation.y={Math.PI}
  scale={[sunRadius, sunRadius, sunRadius]}
  bind:ref={corona}
>
  <T.PlaneGeometry args={[4.4, 4.32]} />
  <T is={Corona}/>
</T.Mesh> -->

<!-- moon -->
<T.Mesh
  visible={false}
  bind:ref={moon}
  position={moonPosition.toArray()}
  rotation={[180 * DEG, 0, 0]}
  castShadow
  fog={false}
>
  <!-- <T.SphereGeometry args={[moonRadius, 32, 32]} /> -->
  <T.IcosahedronGeometry args={[moonRadius, 32]} />
  <!-- <T.CircleGeometry args={[moonRadius, 32]} /> -->
  <T.MeshBasicMaterial color="red" dithering />
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

<T.DirectionalLight
  intensity={1}
  position={sunPosition}
/>

<Earth
  planetVisible={earthVisible}
  mountainsVisible={mountainsVisible}
  planetRadius={planetRadius}
  position={[0, -planetRadius, 0]}
  sunBrightness={sunBrightness}
  sunPosition={sunPosition}
/>

<Jupiter
  position={skyPosition(4.217e8, 5 * DEG, 40 * DEG)}
  radius={7.1492e7}
/>