<script>
  import { Sky, OrbitControls, Grid } from '@threlte/extras'
  import { T } from '@threlte/core'
  import * as THREE from 'three'
  import createCorona from '../shaders/corona/Corona'
  import createTest from '../shaders/test/Test'

  const Corona = createCorona({
    opacity: 0.5
  })
  const DEG = Math.PI / 180
  const FOV = 45

  const Test = createTest()
</script>

<T.PerspectiveCamera
  position={[0, 1, 10]}
  fov={FOV}
  near={1}
  far={20000}
  makeDefault
  on:create={({ ref }) => {
    // ref.lookAt(0, 0, 10)
  }}
>
  <OrbitControls
    enableZoom={true}
    maxPolarAngle={170 * DEG}
    enableDamping
    target={[0, 1, -1]}
  />
</T.PerspectiveCamera>

<!-- <T.Mesh position={[0, 0, -4000]}>
  <T.PlaneGeometry args={[100, 100]} />
  <T is={Corona}/>
</T.Mesh> -->

<T.Mesh position={[0, 0, -4]}>
  <T.SphereGeometry args={[100, 32, 32]} />
  <T is={Test.shader}/>
</T.Mesh>

<!-- Sun -->
<!-- <T.Mesh position={[-0.4, -0.58, -4100]} castShadow>
  <T.SphereGeometry args={[24, 32, 32]} />
  <T.MeshStandardMaterial emissive="white" />
</T.Mesh> -->

<!-- <T.Mesh>
  <T.BoxGeometry args={[200, 200, 200]} />
  <T.MeshStandardMaterial color="black" side={THREE.BackSide} />
</T.Mesh> -->

<T.AmbientLight intensity={0.7}/>
<!-- Grid -->
<Grid
  cellColor="red"
  sectionColor="white"
/>