<script>
  import { useThrelte, useRender, useFrame } from '@threlte/core'
  import { Easing, Tween } from 'intween'
  import { OrbitControls, Grid } from '@threlte/extras'
  import { T } from '@threlte/core'
  import { PlaneGeometry, SphereGeometry, Vector3, MathUtils, Mesh, HemisphereLight } from 'three'
  import {
    EffectComposer,
    EffectPass,
    RenderPass,
    SMAAEffect,
    SMAAPreset,
    BloomEffect,
    GodRaysEffect,
    KernelSize
  } from 'postprocessing'
  import createCorona from '../shaders/corona/Corona'
  import createSky from '../shaders/sky/Sky'

  let sunMaterial

  const Corona = createCorona({
    opacity: 0.5
  })

  const Sky = createSky()

  const DEG = Math.PI / 180
  const { scene, renderer, camera, size } = useThrelte()

  let sun

  const WATTS = 1e-3
  const Lsol = 3.828e26 * WATTS
  // luminocity of earth
  const Learth = 1.74e17 * WATTS

  const FOV = 26.5
  const METER = 1 / 6378
  const Re = 6378 * 1000 * METER
  const AU = 149597870700 * METER

  const elevation = 2 * DEG

  const sunDistance = 1 * AU
  const sunPosition = [0, Math.sin(elevation) * sunDistance, sunDistance]
  const sunRadius = 109 * Re

  const moonPerigee = 356500 * 1000 * METER
  const moonApogee = 406700 * 1000 * METER
  const moonDistance = MathUtils.lerp(moonPerigee, moonApogee, 0.5)
  const moonPosition = [0, Math.sin(elevation) * moonDistance, moonDistance]
  const moonRadius = 0.2727 * Re

  const orbitTarget =  [0, 1, 0]
  let sunBrightness = 1
  $: sunIntensity = sunBrightness * 10000000 * Lsol / (4 * Math.PI * Math.pow(sunDistance, 2))

  const createExpotentialIn = (a) => {
    return (x) => Math.pow(2, a * x - a) * x
  }

  const createExpotentialOut = (a) => {
    return (x) => 1 - Math.pow(2, -a * x) * (1 - x)
  }

  const expoIn = createExpotentialIn(30)
  const expoOut = createExpotentialOut(30)
  const moonMove = new Tween({ theta: -0.6, corona: 0, brightness: 1 })
    .by('2s', { theta: 0, brightness: 0.5 }, 'quadOut')
    .by('2s', { corona: 1 }, expoIn)
    .by('4s', { theta: 0.6, brightness: 1 }, 'quadIn')
    .by('4s', { corona: 0 }, expoOut)
    .by('6s', { theta: 0, brightness: 0.5 }, 'quadOut')
    .by('6s', { corona: 1 }, expoIn)
    .by('8s', { theta: -0.6, brightness: 1 }, 'quadIn')
    .by('8s', { corona: 0 }, expoOut)
    .loop()

  let time = 0
  useFrame((ctx, dt) => {
    // frame
    time += dt * 1000
    const state = moonMove.at(time / 2)
    moonPosition[0] = Math.sin(state.theta * DEG) * moonDistance
    sunMaterial.emissiveIntensity = state.brightness
    sunBrightness = state.brightness
    Corona.uniforms.uOpacity.value = state.corona
    Corona.uniforms.uOpacity.needsUpdate = true
  })

  const composer = new EffectComposer(renderer)
  const setupEffectComposer = (camera, sun) => {
    if (!camera || !sun) return
    composer.removeAllPasses()
    composer.addPass(new RenderPass(scene, camera))
    composer.addPass(
      new EffectPass(
        camera,
        new GodRaysEffect(camera, sun, {
          // resolutionScale: 1,
          density: 0.8,
          decay: 0.9,
          weight: 0.2,
          exposure: 0.6,
          samples: 60,
          clampMax: 1.0
        }),
        new BloomEffect({
          intensity: 1,
          luminanceThreshold: 0.6,
          height: 512,
          width: 512,
          luminanceSmoothing: 0.06,
          mipmapBlur: true,
          kernelSize: KernelSize.MEDIUM
        }),
        new SMAAEffect({
          preset: SMAAPreset.LOW
        })
      )
    )
  }
  // We need to set up the passes according to the camera in use
  $: composer.setSize($size.width, $size.height)
  $: setupEffectComposer($camera, sun)
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
<!-- <T.Mesh>
  <T.SphereGeometry args={[2 * sunDistance, 32, 15]} />
  <T is={Sky.shader} />
</T.Mesh> -->

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
  intensity={sunIntensity}
  color="white"
  castShadow
/>
<T.Mesh
  position={sunPosition}
  bind:ref={sun}
>
  <T.SphereGeometry args={[sunRadius, 32, 32]} />
  <T.MeshBasicMaterial color="#fdffde" bind:ref={sunMaterial} />
</T.Mesh>

<T.Mesh visible={false} position={[-1000, 3000, sunDistance]} rotation.y={Math.PI} scale={[sunRadius, sunRadius, sunRadius]}>
  <T.PlaneGeometry args={[4.3, 4.2]} />
  <T is={Corona}/>
</T.Mesh>

<!-- moon -->
<T.Mesh
  position={moonPosition}
>
  <!-- <T.SphereGeometry args={[moonRadius, 32, 32]} /> -->
  <T.IcosahedronGeometry args={[moonRadius, 30]} />
  <T.MeshStandardMaterial color="black"/>
</T.Mesh>

<!-- Ground -->
<T.Mesh
  position={[0, -0.1, 0]}
  rotation={[-90 * DEG, 0, 0]}
  receiveShadow
>
  <T.PlaneGeometry args={[1000, 1000]} />
  <T.MeshStandardMaterial color='#aa8888'/>
</T.Mesh>

<!-- Grid -->
<!-- <Grid
  cellColor="red"
  sectionColor="white"
/> -->