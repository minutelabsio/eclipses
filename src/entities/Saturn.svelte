<script>
import { DoubleSide, TextureLoader, RingGeometry, Vector3 } from 'three'
import { T, useLoader, forwardEventHandlers } from '@threlte/core'
import textureUrl from '../assets/saturn/saturnmap.jpg'
import ringTextureUrl from '../assets/saturn/saturnringcolor.jpg'
import ringOpacityUrl from '../assets/saturn/saturnringpattern.gif'
import { useSuspense } from '@threlte/extras'
import config from '../configs/saturn'

const component = forwardEventHandlers()

export let time = 0
export let planetRadius = 1
export let position = [0, 0, 0]
export let rotation = [0, 0, .1]
export let visible = true
const RING_OUTER = 2.987
const RING_INNER = 1.11

// setup the rings
const ringGeometry = new RingGeometry(RING_INNER, RING_OUTER, 256);
let pos = ringGeometry.attributes.position;
let v3 = new Vector3();
for (let i = 0; i < pos.count; i++){
  v3.fromBufferAttribute(pos, i);
  ringGeometry.attributes.uv.setXY(i, v3.length() < RING_OUTER - .1 ? 0 : 1, 1);
}

const suspend = useSuspense()
const textures = suspend(useLoader(TextureLoader).load({
  map: textureUrl,
  ring: ringTextureUrl,
  ringOpacity: ringOpacityUrl,
}))
</script>

{#if $textures}
<T.Group position={position} visible={visible} rotation={rotation}>
  <T.Mesh
    rotation.x={2 * Math.PI * time / config.dayLength}
    rotation.z={-Math.PI / 2}
    scale={[planetRadius, planetRadius, planetRadius]}
    receiveShadow
    bind:this={$component}
  >
    <T.IcosahedronGeometry args={[1.00004, 64]} />
    <T.MeshStandardMaterial
      dithering
      map={$textures.map}
      shininess={0}
      fog={false}
    />
  </T.Mesh>
  <!-- Another dummy sphere at scale 1 -->
  <T.Mesh scale={[planetRadius, planetRadius, planetRadius]} renderOrder={0}>
    <T.IcosahedronGeometry args={[0.9999, 64]} />
    <T.MeshStandardMaterial
      dithering
      shininess={0}
      fog={false}
    />
  </T.Mesh>
  <T.Mesh scale={[planetRadius, planetRadius, planetRadius]} rotation.y={Math.PI / 2}>
    <T is={ringGeometry}/>
    <T.MeshStandardMaterial
      dithering
      map={$textures.ring}
      alphaMap={$textures.ringOpacity}
      side={DoubleSide}
      metalness={1}
      transparent
      fog={false}
    />
  </T.Mesh>
</T.Group>
{/if}