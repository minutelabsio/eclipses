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
    mieBaseline,
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
  import * as moonMasks from '../lib/moon-masks.js'
  import { useSuspense } from '@threlte/extras'

  export let fisheye = false

  const Sky = createSky()

  useFrame((ctx, dt) => {
    Sky.update(dt)
  })

  const suspend = useSuspense()

  let textures
  suspend(useLoader(TextureLoader).load(moonMasks)).then((result) => {
    textures = result
  })

  const getTexture = (textures, moon) => {
    if (!textures) return null
    if (moon in textures) {
      return textures[moon]
    }
    return null
  }

  $: scale = 1e-6
  $: Sky.cameraScale = scale
  $: Sky.moonTexture = getTexture(textures, $selectedMoon)
  $: Sky.sunIntensity = $sunIntensity
  $: Sky.rayleighCoefficients = $rayleighCoefficient.clone().multiplyScalar(1/scale)
  $: Sky.rayleighScaleHeight = $rayleighScaleHeight * scale
  $: Sky.mieCoefficients = $mieCoefficient.clone().multiplyScalar(1/scale)
  $: Sky.mieWavelengthResponse = $mieWavelengthResponse
  $: Sky.mieScaleHeight = $mieScaleHeight * scale
  $: Sky.mieDirectional = $mieDirectional
  $: Sky.mieBaseline = $mieBaseline
  $: Sky.ozoneLayerHeight = $ozoneLayerHeight * scale
  $: Sky.ozoneLayerWidth = $ozoneLayerWidth * scale
  $: Sky.ozoneCoefficients = $ozoneCoefficients.clone().multiplyScalar(1/scale)
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
  $: Sky.atmosphereThickness = $atmosphereThickness * scale
  $: Sky.planetRadius = $planetRadius * scale
  $: Sky.sunPosition.set(...$sunPosition).multiplyScalar(scale)
  $: Sky.sunRadius = $sunRadius / METER * scale
  $: Sky.moonPosition.copy($moonPosition).multiplyScalar(scale)
  $: Sky.moonRadius = $moonRadius / METER * scale
  $: Sky.fisheye = fisheye
  $: Sky.uAltitude = ($altitude + 1) * scale

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