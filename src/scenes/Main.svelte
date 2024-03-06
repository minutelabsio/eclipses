<script>
  import Renderer from '../components/Renderer.svelte'
  import Camera from '../components/Camera.svelte'
  import {
    eclipseProgress,
    load,
    planet,
  } from '../store/environment'
  import {
    AU,
  } from '../lib/units'
  import Levetate from '../components/Levetate.svelte'
  import PlanetSelector from '../components/PlanetSelector.svelte'
  import Space from './Space.svelte'
  import * as PlanetConfigs from '../configs'
  import EclipseSlider from '../components/EclipseSlider.svelte'
  import { fade } from 'svelte/transition'

  let selectorActive = false

  const openPlanetSelector = () => {
    selectorActive = true
  }

  const onPlanetSelected = ({ detail }) => {
    const { name } = detail
    const v = name.toLowerCase()
    const moons = Object.values(PlanetConfigs[v].moons)
    load(PlanetConfigs[v])
    load(PlanetConfigs[v].moons[moons[0]])
  }
</script>
<style lang="sass">
.controls
  position: fixed
  bottom: 0
  left: 50%
  width: 100%
  max-width: 660px
  height: 280px
  transform: translateX(-50%)
  z-index: 100
  touch-action: none
  cursor: pointer

  .eclipse-slider
    position: absolute
    top: 7%
    left: 50%
    transform: translateX(-50%)
    height: 280px
    width: 280px
    touch-action: none
    cursor: pointer
    box-shadow: 0 0 50px 0 hsla(0, 0%, 50%, 0.5)
    border-radius: 50%
</style>

<Levetate>
  <div class="controls" class:selector={selectorActive}>
    <PlanetSelector on:select={onPlanetSelected} bind:active={selectorActive} />

    {#if !selectorActive}
      <div transition:fade={{ duration: 100 }} class="eclipse-slider">
        <EclipseSlider on:click={openPlanetSelector} bind:progress={$eclipseProgress}/>
      </div>
    {/if}
  </div>
</Levetate>

<Renderer/>
<Space/>

<Camera
  makeDefault
  near={1}
  far={1.2 * AU}
/>