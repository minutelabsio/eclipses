<script>
  import { Canvas, T } from '@threlte/core'
  import PlanetSelectorScene from './PlanetSelectorScene.svelte'

</script>

<div class="planet-selector">
  <Canvas
  >
    <PlanetSelectorScene />
  </Canvas>
</div>

<style lang="sass">
.planet-selector
  width: 100%
  height: 100%
  display: flex
  flex-grow: 1
  flex: 1
</style>