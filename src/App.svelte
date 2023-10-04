<script>
  import { Canvas } from '@threlte/core'
  import Space from './scenes/Space.svelte'
  import Test from './scenes/Test.svelte'
  import { onMount } from 'svelte'

  const renderOptions = {
    powerPreference: 'high-performance',
    antialias: false,
    stencil: false,
    depth: false,
    alpha: false
  }

  onMount(() => {
    // remove the .ml-spinner element
    document.querySelector('.ml-spinner')?.remove()
  })
</script>

<main>
  <Canvas useLegacyLights={false} rendererParameters={renderOptions}>
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
