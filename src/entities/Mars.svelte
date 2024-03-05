<script>
import { useSuspense } from '@threlte/extras'
import { TextureLoader } from 'three'
import { T, useLoader } from '@threlte/core'
import marsTextureUrl from '../assets/mars/mars_1k_color.jpg'
import marsNormalUrl from '../assets/mars/mars_1k_normal.jpg'

export let planetRadius = 1
export let position = [0, 0, 0]
export let rotation = [2.5, 0, -Math.PI / 2]
export let visible = true

const suspend = useSuspense()

const textures = suspend(useLoader(TextureLoader).load({
  map: marsTextureUrl,
  normalMap: marsNormalUrl,
}))
</script>

{#if $textures}
<T.Group
  position={position}
  visible={visible}
  rotation={rotation}
>
  <T.Mesh
    scale={[planetRadius, planetRadius, planetRadius]}
    receiveShadow
    renderOrder={1}
  >
    <T.IcosahedronGeometry args={[0.9999, 64]} />
    <T.MeshStandardMaterial
      dithering
      map={$textures.map}
      normalMap={$textures.normalMap}
      shininess={0}
      fog={false}
      color={"#ffffff"}
    />
  </T.Mesh>
</T.Group>
{/if}