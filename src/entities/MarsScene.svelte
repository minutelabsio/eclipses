<script>
import { useSuspense } from '@threlte/extras'
import { TextureLoader } from 'three'
import Terrain from './Terrain.svelte'
import { T, useLoader } from '@threlte/core'
import marsTextureUrl from '../assets/mars/mars_1k_color.jpg'
import marsNormalUrl from '../assets/mars/mars_1k_normal.jpg'

export let sunPosition = [0, 0, 0]
export let sunBrightness = 1
export let planetRadius = 1
export let position = [0, 0, 0]
export let rotation = [2.5, 0, -Math.PI / 2]
export let planetColor = 0xa96041
export let visible = true
export let mountainsVisible = true
export let skyColor = 0x71bce1
export let groundColor = 0x71bce1

const suspend = useSuspense()

const textures = suspend(useLoader(TextureLoader).load({
  map: marsTextureUrl,
  normalMap: marsNormalUrl,
}))
</script>

{#if $textures}
<T.LOD let:ref={lod}>
  <T.Group
    on:create={({ ref }) => {
      lod.addLevel(ref, 4000)
    }}
    renderOrder={2}
    layers={9}
  >
    <T.HemisphereLight
      intensity={sunBrightness + .1}
      skyColor={skyColor}
      groundColor={groundColor}
      layers={9}
      castShadow={false}
    />
    <T.Group
      position={position}
    >
      <T.DirectionalLight
        intensity={sunBrightness * 2}
        position={sunPosition}
        layers={9}
        castShadow={false}
      />
    </T.Group>
    <T.Mesh
      position={[0, -planetRadius, 0]}
      rotation={[0, 0, 0]}
      scale={[planetRadius, planetRadius, planetRadius]}
      layers={9}
      renderOrder={1}
      visible={mountainsVisible}
    >
      <T.IcosahedronGeometry args={[1.00005, 64]} />
      <T.MeshStandardMaterial color={planetColor}/>
    </T.Mesh>
    <Terrain color={planetColor} visible={mountainsVisible} layers={9} renderOrder={1} />
  </T.Group>
  <T.Group
    on:create={({ ref }) => {
      lod.addLevel(ref, planetRadius * 0.01)
    }}
  >
    <T.Mesh
      visible={visible}
      position={position}
      rotation={rotation}
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
</T.LOD>
{/if}