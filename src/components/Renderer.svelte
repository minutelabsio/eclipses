<script>
  import * as THREE from 'three'
  import { useThrelte, useTask } from '@threlte/core'
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
  } from 'postprocessing'
  import { exposure, bloomIntensity } from '../store/environment'
  import { onMount } from 'svelte'

  const { scene, renderer, camera, size, renderStage, autoRender } = useThrelte()
  const composer = new EffectComposer(renderer, {
    frameBufferType: THREE.HalfFloatType,
    multisampling: 0
  })

  let bloom = {}

  const setupEffectComposer = async (camera) => {
    if (!camera) return
    composer.removeAllPasses()
    const renderpass = new RenderPass(scene, camera)
    renderpass.selection = new Selection([], 0)
    composer.addPass(renderpass)
    const renderpass2 = new RenderPass(scene, camera)
    renderpass2.clear = false
    renderpass2.selection = new Selection([], 9)
    composer.addPass(renderpass2)

    bloom = new SelectiveBloomEffect(scene, camera, {
      intensity: $bloomIntensity,
      luminanceThreshold: 1.2, //0.5,
      luminanceSmoothing: 0.7,
      blendFunction: BlendFunction.ADD,
      radius: .9, //.99,
      levels: 10, //40,
      mipmapBlur: true
    })
    bloom.dithering = true
    bloom.inverted = true

    composer.addPass(
      new EffectPass(
        camera,
        bloom,
        // new SMAAEffect({
        //   preset: SMAAPreset.LOW,
        //   edgeDetectionMode: EdgeDetectionMode.LUMA,
        //   // edgeDetectionMode: EdgeDetectionMode.DEPTH,
        //   blendFunction: BlendFunction.SCREEN
        // }),
        new ToneMappingEffect({
          // blendFunction: BlendFunction.NORMAL,
          // mode: ToneMappingMode.ACES_FILMIC,
          // mode: ToneMappingMode.REINHARD2,
          mode: ToneMappingMode.REINHARD2_ADAPTIVE,
          // adaptive: true,
          // resolution: 256,
          // middleGrey: 0.6,
          whitePoint: 2,
          minLuminance: 0.005,
          adaptationRate: 2
        }),
      )
    )
  }
  // We need to set up the passes according to the camera in use
  $: setupEffectComposer($camera)
  $: composer.setSize($size.width, $size.height)
  $: bloom.intensity = $bloomIntensity
  $: renderer.toneMappingExposure = $exposure

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
</script>