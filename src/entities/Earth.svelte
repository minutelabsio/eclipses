<script>
import { MeshBasicMaterial, PlaneGeometry, TextureLoader } from 'three'
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
<T.LOD let:ref={lod}>
  <T.Mesh
    position={position}
    rotation={[Math.PI / 2, 0, -Math.PI / 2]}
    scale={[planetRadius, planetRadius, planetRadius]}
    receiveShadow
    on:create={({ ref }) => {
      lod.addLevel(ref, planetRadius * 0.01)
    }}
  >
    <T.IcosahedronGeometry args={[1, 64]} />
    <T.MeshPhongMaterial
      dithering
      map={$textures.map}
      normalMap={$textures.normalMap}
      specularMap={$textures.specularMap}
      shininess={0}
    />
  </T.Mesh>
</T.LOD>
{/if}