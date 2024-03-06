<script>
  import { createEventDispatcher, onMount } from 'svelte'
  import { T, useFrame } from '@threlte/core'
  import { interactivity } from '@threlte/extras'
  import Jupiter from '../entities/Jupiter.svelte'
  import Saturn from '../entities/Saturn.svelte'
  import Earth from '../entities/Earth.svelte'
  import Mars from '../entities/Mars.svelte'
  import Uranus from '../entities/Uranus.svelte'
  import Neptune from '../entities/Neptune.svelte'
  import { Subject, map, smoothen } from 'intween'

  export let pos = 0
  export let spotlight = false
  export let showAll = false

  const stateChange = new Subject()

  interactivity()

  const dispatch = createEventDispatcher()
  const planetClicked = (planet) => (e) => {
    dispatch('planetClicked', {
      planet
    })
  }

  const planetAngles = Array.from({ length: 6 }, (_, i) => i * Math.PI / 3)
  let planetTilts = []
  const tilt = 0.5
  const rotation = [0, 0, 0]
  const dollyRadius = 3
  let nonSelectedScale = 1

  const getPlanetStates = (pos, x) => {
    const theta = -(pos - 2 * Math.PI) % (2 * Math.PI)
    // based on the current position, planetStates up.scale the appropriate planet
    // and planetStates do.scalewn the others
    const states = planetAngles.map((angle, i) => {
      let distance = Math.abs(angle - theta)
      distance = Math.min(distance, Math.abs(2 * Math.PI - distance))
      const scale = 1 / (1 + distance / x)
      return { scale, r: x * dollyRadius + 0.01 }
    })
    return states
  }

  stateChange.pipe(
    map(({ showAll }) => {
      if (showAll) {
        const planetTilts = [
          0, // earth
          0, // mars
          0, // jupiter
          Math.PI / 2, // saturn
          -0.5, // uranus
          0 // neptune
        ]
        return { scale: 1, showAll, planetTilts }
      } else {
        const planetTilts = [
          -1, // earth
          -1, // mars
          -1, // jupiter
          0.5, // saturn
          -0.5, // uranus
          -1 // neptune
        ]
        return { scale: 1e-2, showAll, planetTilts }
      }
    }),
    smoothen({ duration: '0.5s', easing: 'quadOut' })
  ).subscribe((state) => {
    nonSelectedScale = state.scale
    planetTilts = state.planetTilts
  })

  setTimeout(() => {
    stateChange.next({ showAll })
  }, 10)

  $: planetStates = getPlanetStates(pos, nonSelectedScale)
  $: stateChange.next({ showAll })

  let time = 0
  useFrame((ctx, dt) => {
    rotation[1] = pos
    time += 1e3 * dt
  })
</script>

<T.PerspectiveCamera
  makeDefault={true}
  position={[0, 0.2, 5]}
  lookAt={[0, 0, 0]}
  fov={35}
/>
<T.AmbientLight intensity={0.2} />
<T.DirectionalLight intensity={0.5} position={[0, 1, 5]} />
<T.SpotLight visible={spotlight} intensity={20 * (Math.sin(time / 250) + 0.8)} position={[0, 2, 5]} distance={6} />
<T.Group
  rotation={[tilt, 0, 0]}
>
  <T.Group
    position={[0, 0, -2.5 * nonSelectedScale]}
    rotation={rotation}
  >
    <T.Group rotation.y={planetAngles[0]}>
      <T.Group position.z={planetStates[0].r} scale.x={planetStates[0].scale} scale.y={planetStates[0].scale} scale.z={planetStates[0].scale}>
        <Earth
          time={time}
          rotation={[planetTilts[0], Math.PI / 2, 0]}
          on:click={planetClicked('earth')}
        />
      </T.Group>
    </T.Group>
    <T.Group rotation.y={planetAngles[1]}>
      <T.Group position.z={planetStates[1].r} scale.x={planetStates[1].scale} scale.y={planetStates[1].scale} scale.z={planetStates[1].scale}>
        <Mars
          time={time}
          rotation={[planetTilts[1], Math.PI / 2, 0]}
          on:click={planetClicked('mars')}
        />
      </T.Group>
    </T.Group>
    <T.Group rotation.y={planetAngles[2]}>
      <T.Group position.z={planetStates[2].r} scale.x={planetStates[2].scale} scale.y={planetStates[2].scale} scale.z={planetStates[2].scale}>
        <Jupiter
          time={time}
          rotation={[planetTilts[2], Math.PI / 2, 0]}
          on:click={planetClicked('jupiter')}
        />
      </T.Group>
    </T.Group>
    <T.Group rotation.y={planetAngles[3]}>
      <T.Group position.z={planetStates[3].r} scale.x={planetStates[3].scale} scale.y={planetStates[3].scale} scale.z={planetStates[3].scale}>
        <Saturn
          time={time}
          rotation={[planetTilts[3], Math.PI / 2, 0]}
          on:click={planetClicked('saturn')}
        />
      </T.Group>
    </T.Group>
    <T.Group rotation.y={planetAngles[4]}>
      <T.Group position.z={planetStates[4].r} scale.x={planetStates[4].scale} scale.y={planetStates[4].scale} scale.z={planetStates[4].scale}>
        <Uranus
          time={time}
          rotation={[planetTilts[4], Math.PI / 2, 0]}
          on:click={planetClicked('uranus')}
        />
      </T.Group>
    </T.Group>
    <T.Group rotation.y={planetAngles[5]}>
      <T.Group position.z={planetStates[5].r} scale.x={planetStates[5].scale} scale.y={planetStates[5].scale} scale.z={planetStates[5].scale}>
        <Neptune
          time={time}
          rotation={[planetTilts[5], Math.PI / 2, 0]}
          on:click={planetClicked('neptune')}
        />
      </T.Group>
    </T.Group>

    <!-- <T.GridHelper args={[10, 10]} /> -->
  </T.Group>
</T.Group>
