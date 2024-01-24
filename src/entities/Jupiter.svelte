<script>
import { TextureLoader } from 'three'
import { T, useLoader } from '@threlte/core'
import textureUrl from '../assets/jupiter/jupiter_nasa_4k.jpg'

export let radius = 1
export let position = [0, 0, 0]
export let visible = true

const textures = useLoader(TextureLoader).load({
  map: textureUrl,
})
</script>

{#if $textures}
<T.Group>
  <T.Mesh
    visible={visible}
    position={position}
    rotation={[0, 0, 0]}
    scale={[radius, radius, radius]}
    receiveShadow
    renderOrder={1}
  >
    <T.IcosahedronGeometry args={[1, 64]} />
    <T.MeshStandardMaterial
      dithering
      map={$textures.map}
      shininess={0}
      fog={false}
    />
  </T.Mesh>
</T.Group>
{/if}