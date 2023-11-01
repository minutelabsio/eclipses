<script>
import { TextureLoader } from 'three'
import { T, useLoader } from '@threlte/core'
import earthTextureUrl from '../assets/earth/Earth.png'
import earthNormalUrl from '../assets/earth/normal/hires/EarthNormal.png'
import earthSpecularUrl from '../assets/earth/spec/hires/EarthSpec.png'

export let planetRadius = 1
export let position = [0, 0, 0]

const textures = useLoader(TextureLoader).load({
  map: earthTextureUrl,
  normalMap: earthNormalUrl,
  specularMap: earthSpecularUrl,
})
</script>

{#if $textures}
<T.Mesh
  position={position}
>
  <T.IcosahedronGeometry args={[planetRadius, 256]} />
  <T.MeshPhongMaterial
    dithering
    depthTest={false}
    map={$textures.map}
    normalMap={$textures.normalMap}
    specularMap={$textures.specularMap}
  />
</T.Mesh>
{/if}