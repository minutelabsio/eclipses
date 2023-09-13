<script>
  import { useThrelte, useRender, useFrame } from '@threlte/core'
  import { Sky, OrbitControls, Grid } from '@threlte/extras'
  import { T } from '@threlte/core'
  import { PlaneGeometry, SphereGeometry, Vector3 } from 'three'
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

  const DEG = Math.PI / 180
  const { scene, renderer, camera, size } = useThrelte()

  let sun
  const composer = new EffectComposer(renderer)
  const setupEffectComposer = (camera, sun) => {
    if (!camera || !sun) return
    composer.removeAllPasses()
    composer.addPass(new RenderPass(scene, camera))
    composer.addPass(
      new EffectPass(
        camera,
        new GodRaysEffect(camera, sun, {
          resolutionScale: 1,
          density: 0.8,
          decay: 0.5,
          weight: 0.7,
          samples: 60
        })
      )
    )
    composer.addPass(
      new EffectPass(
        camera,
        new SMAAEffect({
          preset: SMAAPreset.LOW
        })
      )
    )
  }
  // We need to set up the passes according to the camera in use
  $: setupEffectComposer($camera, sun)
  $: composer.setSize($size.width, $size.height)
  useRender((_, delta) => {
    composer.render(delta)
  })

  const WATTS = 1e-3
  const Lsol = 3.828e26 * WATTS
  // luminocity of earth
  const Learth = 1.74e17 * WATTS

  const FOV = 26.5
  const METER = 1 / 6378
  const Re = 6378 * 1000 * METER
  const AU = 149597870700 * METER

  const sunDistance = 1 * AU
  const sunPosition = [0, 0, sunDistance]
  const sunRadius = 109 * Re

  const moonDistance = 384399 * 1000 * METER
  const moonPosition = [0, 0, moonDistance]
  const moonRadius = 0.2727 * Re

  const orbitTarget = moonPosition // [0, 1, 0]

  let time = 0
  useFrame((ctx, dt) => {
    // frame
    time += dt
    moonPosition[0] = 400 * Math.cos(time / 2)
  })
</script>

<!-- <T.AmbientLight intensity={Learth}/> -->
<!-- <Sky elevation={0.1} /> -->

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
<T.DirectionalLight
  position={sunPosition}
  intensity={Lsol}
  castShadow
  color="yellow"
/>
<T.Mesh
  position={sunPosition}
  bind:ref={sun}
  castShadow
>
  <T.SphereGeometry args={[sunRadius, 32, 32]} />
  <T.MeshStandardMaterial emissive="yellow" />
</T.Mesh>

<!-- moon -->
<T.Mesh
  position={moonPosition}
  castShadow
>
  <T.SphereGeometry args={[moonRadius, 32, 32]} />
  <T.MeshStandardMaterial color="white"/>
</T.Mesh>

<!-- Ground -->
<!-- <T.Mesh
  position={spherePos}
  rotation={[-90 * DEG, 0, 0]}
  castShadow
>
  <T is={sphereGeo} />
  <T.MeshStandardMaterial />
</T.Mesh> -->

<!-- Grid -->
<Grid
  cellColor="red"
  sectionColor="white"
/>