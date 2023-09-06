<script>
  import { Canvas } from '@threlte/core'
  import { Sky, OrbitControls, Grid } from '@threlte/extras'
  import { T } from '@threlte/core'
  import { PlaneGeometry, SphereGeometry, Vector3 } from 'three'
  import { onMount } from 'svelte'
  const DEG = Math.PI / 180

  onMount(() => {
    // remove the .ml-spinner element
    document.querySelector('.ml-spinner')?.remove()
  })

  const sunPosition = [0, 10, 10]
  const r = 10000
  const sphereGeo = new PlaneGeometry(10000, 10000)
  const spherePos = [0, -1, 0]
</script>

<main>
  <Canvas>
    <T.AmbientLight intensity={0.7}/>
    <Sky elevation={0.5} />

    <T.PerspectiveCamera
      position={[0, 0, 18]}
      fov={60}
      near={1}
      far={20000}
      makeDefault
      on:create={({ ref }) => {
        ref.lookAt(0, 10000, 0)
      }}
    >
      <OrbitControls
        enableZoom={true}
        maxPolarAngle={90 * DEG}
        enableDamping
        target={[0, 2.5, 0]}
      />
    </T.PerspectiveCamera>


    <T.Mesh
      position={spherePos}
      rotation={[-90 * DEG, 0, 0]}
      castShadow
    >
      <T is={sphereGeo} />
      <T.MeshStandardMaterial />
    </T.Mesh>

    <Grid
      cellColor="white"
      sectionColor="white"
    />
  </Canvas>
</main>

<style lang="sass">
  main
    display: flex
    flex-grow: 1
</style>
