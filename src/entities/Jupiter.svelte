<script>
import { TextureLoader } from 'three'
import { T, useLoader, forwardEventHandlers } from '@threlte/core'
import textureUrl from '../assets/jupiter/jupiter_nasa_4k.jpg'
import { useSuspense } from '@threlte/extras'
import config from '../configs/jupiter'

export let time = 0
export let planetRadius = 1
export let position = [0, 0, 0]
export let rotation = [2.5, 0, -Math.PI / 2]
export let visible = true

const component = forwardEventHandlers()

const suspend = useSuspense()
const textures = suspend(useLoader(TextureLoader).load({
  map: textureUrl,
}))
</script>

{#if $textures}
<T.Group
  visible={visible}
  position={position}
  rotation={rotation}
>
  <T.Mesh
    rotation.y={2 * Math.PI * time / config.dayLength}
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
</T.Group>
{/if}