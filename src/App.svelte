<script>
  import { Canvas } from '@threlte/core'
  import Space from './scenes/Space.svelte'
  import { onMount } from 'svelte'

  onMount(() => {
    // remove the .ml-spinner element
    document.querySelector('.ml-spinner')?.remove()
  })
</script>

<main>
  <Canvas>
    <Space />
  </Canvas>
</main>

<style lang="sass">
  main
    display: flex
    flex-grow: 1
</style>
