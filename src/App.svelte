<script>
  import { Canvas } from '@threlte/core'
  import Space from './scenes/Space.svelte'
  import Test from './scenes/Test.svelte'
  import { onMount } from 'svelte'
  import { NoToneMapping } from 'three'

  const renderOptions = {
    powerPreference: 'high-performance',
    antialias: false,
    stencil: false,
    depth: false,
    alpha: false,
  }

  onMount(() => {
    // remove the .ml-spinner element
    document.querySelector('.ml-spinner')?.remove()
  })
</script>

<main>
  <Canvas
    useLegacyLights={false}
    rendererParameters={renderOptions}
    toneMapping={NoToneMapping}
  >
    <Space/>
    <!-- <Test /> -->
  </Canvas>
</main>

<style lang="sass">
  main
    background: black
    display: flex
    flex-grow: 1
    flex: 1
</style>
