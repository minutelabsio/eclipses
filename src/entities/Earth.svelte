<script>
import { Group, MeshBasicMaterial, PlaneGeometry, TextureLoader, Vector3 } from 'three'
import Terrain from '../entities/Terrain.svelte'
import { T, useLoader } from '@threlte/core'
import earthTextureUrl from '../assets/earth/Earth.png'
import earthNormalUrl from '../assets/earth/normal/hires/EarthNormal.png'
import earthSpecularUrl from '../assets/earth/spec/hires/EarthSpec.png'

export let sunPosition = [0, 0, 0]
export let sunBrightness = 1
export let planetRadius = 1
export let position = [0, 0, 0]
export let planetColor = 0x886666
export let planetVisible = true
export let mountainsVisible = true
export let skyColor = 0x71bce1
export let groundColor = 0x71bce1

const textures = useLoader(TextureLoader).load({
  map: earthTextureUrl,
  normalMap: earthNormalUrl,
  specularMap: earthSpecularUrl,
})
</script>

{#if $textures}
<T.LOD let:ref={lod}>
  <T.Group
    on:create={({ ref }) => {
      lod.addLevel(ref, 100)
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
    <T.DirectionalLight
      intensity={sunBrightness * 2}
      position={sunPosition}
      layers={9}
      castShadow={false}
    />
    <T.Mesh
      position={[0, -planetRadius, 0]}
      rotation={[0, 0, 0]}
      scale={[planetRadius, planetRadius, planetRadius]}
      layers={9}
      renderOrder={1}
    >
      <T.IcosahedronGeometry args={[1.0, 64]} />
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
      visible={planetVisible}
      position={position}
      rotation={[Math.PI / 2, 0, -Math.PI / 2]}
      scale={[planetRadius, planetRadius, planetRadius]}
      receiveShadow
      renderOrder={1}
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
</T.LOD>
{/if}