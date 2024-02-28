<script>
  import { T, useFrame } from '@threlte/core'
  import { interactivity } from '@threlte/extras'
  import { createDragger } from '../lib/dragger'
  import Jupiter from '../entities/Jupiter.svelte'
  import Saturn from '../entities/Saturn.svelte'

  const tilt = 0.6
  const rotation = [0, 0, 0]
  const drag = createDragger([0, 0], {
    friction: 0.02,
    threshold: 1e-4,
    minFlick: 1e-3,
    maxFlick: 3e-2,
  })
  interactivity({
    filter: (hits, state) => {
      // Only return the first hit
      return hits.slice(0, 1)
    }
  })

  const getPos = (e) => [e.pointer.x, e.pointer.y]

  // TODO: Different strategy: use a tween to rotate the group
  // Calculate the velocity and then the end position
  //
  let rot = 0
  useFrame(() => {
    const pos = drag.update()
    rotation[1] = (pos[0]) % (Math.PI * 2)
  })
</script>

<T.PerspectiveCamera
  makeDefault={true}
  position={[0, 0, 3]}
  lookAt={[0, 0, 0]}
  fov={75}
/>
<T.AmbientLight intensity={0.5} />
<T.DirectionalLight intensity={1} position={[1, 1, 1]} />
<svelte:window on:pointerup={() => {
  drag.stop()
}} />
<T.Group
  rotation={[tilt, 0, 0]}
  on:pointerdown={(e) => {
    drag.start(getPos(e))
  }}
  on:pointermove={(e) => {
    drag.drag(getPos(e))
  }}
  on:pointerup={(e) => {
    drag.stop(getPos(e))
  }}
>
  <T.Group
    position={[0, 0, -3.5]}
    rotation={rotation}
  >
    <Jupiter
      position={[0, 0, 4]}
      rotation={[0, Math.PI / 2, 0]}
    />
    <Saturn
      position={[0, 0, -4]}
      rotation={[Math.PI / 2, Math.PI / 2, 0]}
    />
    <T.GridHelper args={[10, 10]} />
  </T.Group>
</T.Group>
