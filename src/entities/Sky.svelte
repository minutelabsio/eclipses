<script>
  import { TextureLoader } from 'three'
  import { useFrame, useLoader } from '@threlte/core'
  import createSky from '../shaders/sky/Sky'
  import { T } from '@threlte/core'
  import {
    telescopeMode,
    altitude,
    planetRadius,
    atmosphereThickness,
    sunIntensity,
    sunPosition,
    sunRadius,
    moonRadius,
    moonPosition,
    rayleighCoefficient,
    rayleighScaleHeight,
    mieCoefficient,
    mieWavelengthResponse,
    mieScaleHeight,
    mieDirectional,
    ozoneLayerHeight,
    ozoneLayerWidth,
    ozoneCoefficients,
    exposure,
    iSteps,
    jSteps,
    cloudZ,
    cloudThickness,
    cloudSize,
    cloudMie,
    cloudThreshold,
    cloudAbsorption,
    windSpeed,
    skyVisible,
    selectedMoon,
  } from '../store/environment'
  import {
    METER,
    AU,
  } from '../lib/units'
  import Thalassa from '../assets/moon-stencils/Thalassa.png'
  import { useSuspense } from '@threlte/extras'

  export let fisheye = false

  const Sky = createSky()

  useFrame((ctx, dt) => {
    Sky.update(dt)
  })

  const suspend = useSuspense()

  let textures
  suspend(useLoader(TextureLoader).load({
    thalassa: Thalassa,
  })).then((result) => {
    textures = result
  })

  const getTexture = (textures, moon) => {
    if (!textures) return null
    if (moon in textures) {
      return textures[moon]
    }
    return null
  }

  $: Sky.moonTexture = getTexture(textures, $selectedMoon)
  $: Sky.sunIntensity = $sunIntensity
  $: Sky.rayleighCoefficients = $rayleighCoefficient
  $: Sky.rayleighScaleHeight = $rayleighScaleHeight
  $: Sky.mieCoefficients = $mieCoefficient
  $: Sky.mieWavelengthResponse = $mieWavelengthResponse
  $: Sky.mieScaleHeight = $mieScaleHeight
  $: Sky.mieDirectional = $mieDirectional
  $: Sky.ozoneLayerHeight = $ozoneLayerHeight
  $: Sky.ozoneLayerWidth = $ozoneLayerWidth
  $: Sky.ozoneCoefficients = $ozoneCoefficients
  // $: Sky.exposure = $exposure
  $: Sky.iSteps = $iSteps
  $: Sky.jSteps = $jSteps
  $: Sky.cloudZ = $cloudZ
  $: Sky.cloudThickness = $telescopeMode ? 0 : $cloudThickness
  $: Sky.cloudSize = $cloudSize
  $: Sky.cloudMie = $cloudMie
  $: Sky.cloudThreshold = $cloudThreshold
  $: Sky.cloudAbsorption = $cloudAbsorption
  $: Sky.windSpeed = $windSpeed
  $: Sky.atmosphereThickness = $atmosphereThickness
  $: Sky.planetRadius = $planetRadius
  $: Sky.sunPosition.set(...$sunPosition)
  $: Sky.sunRadius = $sunRadius / METER
  $: Sky.moonPosition.copy($moonPosition)
  $: Sky.moonRadius = $moonRadius / METER
  $: Sky.fisheye = fisheye
  $: Sky.uAltitude = $altitude

  // $: Sky.shader.blendEquation = $altitude > $atmosphereThickness * 0.9 ? THREE.AddEquation : THREE.MaxEquation

</script>

{#if fisheye}
<T.Mesh
  visible={$skyVisible}
  renderOrder={2}
>
  <T.PlaneGeometry args={[6, 6]} />
  <!-- <T.MeshBasicMaterial color={0xff0000} /> -->
  <T is={Sky.shader} />
</T.Mesh>
{:else}
<T.Mesh
  visible={$skyVisible}
  scale.x={0.5 * AU}
  scale.y={0.5 * AU}
  scale.z={0.5 * AU}
  renderOrder={2}
>
  <T.IcosahedronGeometry args={[1, 32]} />
  <T is={Sky.shader} />
</T.Mesh>
{/if}