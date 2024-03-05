<script>
import { useSuspense } from '@threlte/extras'
import { TextureLoader } from 'three'
import { T, useLoader, forwardEventHandlers } from '@threlte/core'
import earthTextureUrl from '../assets/earth/Earth.png'
import earthNormalUrl from '../assets/earth/normal/hires/EarthNormal.png'
import earthSpecularUrl from '../assets/earth/spec/hires/EarthSpec.png'

export let planetRadius = 1
export let position = [0, 0, 0]
export let rotation = [Math.PI / 2, 0, -Math.PI / 2]
export let visible = true

const component = forwardEventHandlers()

const suspend = useSuspense()

const textures = suspend(useLoader(TextureLoader).load({
  map: earthTextureUrl,
  normalMap: earthNormalUrl,
  specularMap: earthSpecularUrl,
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
      bind:this={$component}
    >
      <T.IcosahedronGeometry args={[0.9999, 64]} />
      <T.MeshPhongMaterial
        dithering
        map={$textures.map}
        normalMap={$textures.normalMap}
        specularMap={$textures.specularMap}
        shininess={0}
        fog={false}
      />
    </T.Mesh>
  </T.Group>
{/if}