<script>
  import * as THREE from 'three'
  import { useThrelte, useTask } from '@threlte/core'
  import { useSuspense } from '@threlte/extras'
  import {
    EffectComposer,
    EffectPass,
    RenderPass,
    SMAAEffect,
    SMAAPreset,
    SelectiveBloomEffect,
    BlendFunction,
    ToneMappingEffect,
    ToneMappingMode,
    Selection,
    EdgeDetectionMode,
    LUT3DEffect,
    LookupTexture
  } from 'postprocessing'
  import { exposure, bloomIntensity, telescopeMode, telescopeModeExposure } from '../store/environment'
  import { onMount } from 'svelte'
  import { getGPUTier } from 'detect-gpu'
  import { setQuality } from '../store/environment'

  export let lutPre = null
  export let lutPost = null

  const detectGpu = async () => {
    // detect the gpu tier and adjust settings
    const gpuTier = await getGPUTier()
    setQuality(gpuTier.tier)

    // Example output:
    // {
    //   "tier": 1,
    //   "isMobile": false,
    //   "type": "BENCHMARK",
    //   "fps": 21,
    //   "gpu": "intel iris graphics 6100"
    // }
  }

  const { scene, renderer, camera, size, renderStage, autoRender } = useThrelte()
  const composer = new EffectComposer(renderer, {
    frameBufferType: THREE.HalfFloatType,
    multisampling: 0
  })

  let bloom = {}

  const setupEffectComposer = async (camera, lutPre, lutPost) => {
    if (!camera) return
    composer.removeAllPasses()
    const renderpass = new RenderPass(scene, camera)
    renderpass.skipShadowMapUpdate = true
    // TODO: in the new version of postprocessing this 0 throws an error. need to figure out how to change to 1
    renderpass.selection = new Selection([], 0)
    composer.addPass(renderpass)
    const renderpass2 = new RenderPass(scene, camera)
    renderpass2.clear = false
    renderpass2.selection = new Selection([], 9)
    composer.addPass(renderpass2)

    bloom = new SelectiveBloomEffect(scene, camera, {
      intensity: $bloomIntensity,
      luminanceThreshold: 2.5, //0.5,
      luminanceSmoothing: 0.7,
      blendFunction: BlendFunction.ADD,
      radius: .9, //.99,
      levels: 10, //40,
      mipmapBlur: true
    })
    bloom.dithering = true
    bloom.inverted = true

    const lutPreEffect = lutPre && new LUT3DEffect(lutPre)
    const lutPostEffect = lutPost && new LUT3DEffect(lutPost)

    const effects = [
      new SMAAEffect({
        preset: SMAAPreset.ULTRA,
        edgeDetectionMode: EdgeDetectionMode.LUMA,
        // blendFunction: BlendFunction.SCREEN
      }),
      bloom,
      // new SMAAEffect({
      //   preset: SMAAPreset.LOW,
      //   edgeDetectionMode: EdgeDetectionMode.LUMA,
      //   // edgeDetectionMode: EdgeDetectionMode.DEPTH,
      //   blendFunction: BlendFunction.SCREEN
      // }),
      lutPreEffect,
      new ToneMappingEffect({
        // blendFunction: BlendFunction.NORMAL,
        // mode: ToneMappingMode.ACES_FILMIC,
        // mode: ToneMappingMode.REINHARD2,
        // mode: ToneMappingMode.NEUTRAL,
        mode: ToneMappingMode.REINHARD2_ADAPTIVE,
        // adaptive: true,
        // resolution: 256,
        // middleGrey: 0.6,
        whitePoint: 10,
        // middleGrey: 1,
        minLuminance: 0.0006, //0.0000025,
        adaptationRate: 2,
      }),
      lutPostEffect
    ].filter(Boolean)

    composer.addPass(
      new EffectPass(
        camera,
        ...effects
      )
    )
  }
  // We need to set up the passes according to the camera in use
  $: setupEffectComposer($camera, lutPre, lutPost)
  $: composer.setSize($size.width, $size.height)
  $: bloom.intensity = $bloomIntensity
  $: renderer.toneMappingExposure = $telescopeMode ? $telescopeModeExposure : $exposure

  onMount(() => {
    let auto = autoRender.current
    autoRender.set(false)

    return () => {
      autoRender.set(auto)
    }
  })

  useTask((delta) => {
    if (!renderer){ return }
    composer.render(delta)
  }, { stage: renderStage, autoInvalidate: false })

  const suspend = useSuspense()
  suspend(detectGpu())
</script>
