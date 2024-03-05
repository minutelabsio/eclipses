<script>
  import * as PlanetConfigs from '../configs'
  import { createEventDispatcher } from 'svelte'
  import { T, useFrame } from '@threlte/core'
  import { interactivity } from '@threlte/extras'
  import Jupiter from '../entities/Jupiter.svelte'
  import Saturn from '../entities/Saturn.svelte'
  import Earth from '../entities/Earth.svelte'
  import Mars from '../entities/Mars.svelte'
  import Uranus from '../entities/Uranus.svelte'
  import Neptune from '../entities/Neptune.svelte'

  export let pos = 0

  interactivity()

  const dispatch = createEventDispatcher()
  const planetClicked = (planet) => (e) => {
    dispatch('planetClicked', {
      planet
    })
  }

  const planetAngles = Array.from({ length: 6 }, (_, i) => i * Math.PI / 3)
  const tilt = 0.4
  const rotation = [0, 0, 0]
  const dollyRadius = 3

  const getScales = (pos) => {
    const theta = -(pos - 2 * Math.PI) % (2 * Math.PI)
    // based on the current position, scales up the appropriate planet
    // and scales down the others
    const scales = planetAngles.map((angle, i) => {
      let distance = Math.abs(angle - theta)
      distance = Math.min(distance, Math.abs(2 * Math.PI - distance))
      return 1 / (1 + distance)
    })
    return scales
  }

  $: scales = getScales(pos)

  let time = 0
  useFrame((ctx, dt) => {
    rotation[1] = pos
    time += 1e3 * dt
  })
</script>

<T.PerspectiveCamera
  makeDefault={true}
  position={[0, 0, 8]}
  lookAt={[0, 0, 0]}
  fov={35}
/>
<T.AmbientLight intensity={0.2} />
<T.DirectionalLight intensity={0.5} position={[0, 1, 5]} />
<T.Group
  rotation={[tilt, 0, 0]}
>
  <T.Group
    position={[0, 0, -2.5]}
    rotation={rotation}
  >
    <T.Group rotation.y={planetAngles[0]}>
      <T.Group position={[0, 0, dollyRadius]} scale.x={scales[0]} scale.y={scales[0]} scale.z={scales[0]}>
        <Earth
          time={time}
          rotation={[0, Math.PI / 2, 0]}
          on:click={planetClicked('earth')}
        />
      </T.Group>
    </T.Group>
    <T.Group rotation.y={planetAngles[1]}>
      <T.Group position={[0, 0, dollyRadius]} scale.x={scales[1]} scale.y={scales[1]} scale.z={scales[1]}>
        <Mars
          time={time}
          rotation={[0, Math.PI / 2, 0]}
          on:click={planetClicked('mars')}
        />
      </T.Group>
    </T.Group>
    <T.Group rotation.y={planetAngles[2]}>
      <T.Group position={[0, 0, dollyRadius]} scale.x={scales[2]} scale.y={scales[2]} scale.z={scales[2]}>
        <Jupiter
          time={time}
          rotation={[0, Math.PI / 2, 0]}
          on:click={planetClicked('jupiter')}
        />
      </T.Group>
    </T.Group>
    <T.Group rotation.y={planetAngles[3]}>
      <T.Group position={[0, 0, dollyRadius]} scale.x={scales[3]} scale.y={scales[3]} scale.z={scales[3]}>
        <Saturn
          time={time}
          rotation={[Math.PI / 2, Math.PI / 2, 0]}
          on:click={planetClicked('saturn')}
        />
      </T.Group>
    </T.Group>
    <T.Group rotation.y={planetAngles[4]}>
      <T.Group position={[0, 0, dollyRadius]} scale.x={scales[4]} scale.y={scales[4]} scale.z={scales[4]}>
        <Uranus
          time={time}
          rotation={[-0.5, Math.PI / 2, 0]}
          on:click={planetClicked('uranus')}
        />
      </T.Group>
    </T.Group>
    <T.Group rotation.y={planetAngles[5]}>
      <T.Group position={[0, 0, dollyRadius]} scale.x={scales[5]} scale.y={scales[5]} scale.z={scales[5]}>
        <Neptune
          time={time}
          rotation={[0, Math.PI / 2, 0]}
          on:click={planetClicked('neptune')}
        />
      </T.Group>
    </T.Group>

    <!-- <T.GridHelper args={[10, 10]} /> -->
  </T.Group>
</T.Group>
