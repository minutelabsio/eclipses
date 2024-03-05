<script>
import { Color, DoubleSide, RingGeometry, TextureLoader, Vector3 } from 'three'
import { T, useLoader, forwardEventHandlers } from '@threlte/core'
import textureUrl from '../assets/uranus/uranusmap.jpg'
import ringTextureUrl from '../assets/uranus/uranusringcolor.jpg'
import ringOpacityUrl from '../assets/uranus/uranusringtrans.gif'
import { useSuspense } from '@threlte/extras'
import { altitude, atmosphereThickness } from '../store/environment'

const component = forwardEventHandlers()

export let planetRadius = 1
export let position = [0, 0, 0]
export let rotation = [0, -0.05, .2]
export let visible = true
const RING_OUTER = 2.006
const RING_INNER = 1.637

// setup the rings
const ringGeometry = new RingGeometry(RING_INNER, RING_OUTER, 256);
let pos = ringGeometry.attributes.position;
let v3 = new Vector3();
for (let i = 0; i < pos.count; i++){
  v3.fromBufferAttribute(pos, i);
  ringGeometry.attributes.uv.setXY(i, v3.length() < RING_OUTER - 0.1 ? 0 : 1, 1);
}

const suspend = useSuspense()
const textures = suspend(useLoader(TextureLoader).load({
  map: textureUrl,
  ring: ringTextureUrl,
  ringOpacity: ringOpacityUrl,
}))

$: colorFade = new Color(0x000000).lerp(new Color(0xffffff), Math.min(1, $altitude / $atmosphereThickness))
</script>

{#if $textures}
<T.Group position={position} visible={visible} rotation={rotation}>
  <T.Mesh
    visible={visible}
    rotation={[0, 0, -Math.PI / 2]}
    scale={[planetRadius, planetRadius, planetRadius]}
    receiveShadow
    renderOrder={1}
    bind:this={$component}
  >
    <T.IcosahedronGeometry args={[0.9999, 64]} />
    <T.MeshStandardMaterial
      dithering
      map={$textures.map}
      shininess={0}
      fog={false}
    />
  </T.Mesh>
  <!-- rings -->
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