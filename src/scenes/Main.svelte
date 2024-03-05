<script>
  import Renderer from '../components/Renderer.svelte'
  import Camera from '../components/Camera.svelte'
  import {
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
  height: 480px
  transform: translateX(-50%)
  z-index: 100
  background: rgba(0, 0, 0, 0.5)
  touch-action: none
</style>

<Levetate>
  <div class="controls">
    <PlanetSelector on:change={onPlanetSelected} />
  </div>
</Levetate>

<Renderer/>
<Space/>

<Camera
  makeDefault
  near={1}
  far={1.2 * AU}
/>