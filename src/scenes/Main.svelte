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
  import Icon from '@iconify/svelte'
  import { Player } from 'intween'

  let element
  let selectorActive = false
  const player = Player.create(10000)
  let playing = !player.paused

  player.on('play', () => {
    if (player.progress === 100) {
      player.seek(0)
    }
  })

  player.on('togglePause', () => {
    playing = !player.paused
  })

  player.on('update', () => {
    eclipseProgress.set(player.progress / 100)
  })

  eclipseProgress.subscribe((v) => {
    if (player.paused){
      player.progress = v * 100
    }
  })

  let wasPlaying = false
  const seekStart = () => {
    wasPlaying = !player.paused
    if (wasPlaying) {
      player.pause()
    }
  }

  const seekEnd = () => {
    if (wasPlaying) {
      player.play()
    }
  }

  const togglePlay = () => {
    if (playing) {
      player.pause()
    } else {
      player.play()
    }
  }

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

  const onSwipe = ({ detail }) => {
    if (detail.direction === 'up') {
      selectorActive = true
    }
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

  .play-pause
    position: absolute
    top: 50%
    left: 50%
    transform: translate(-50%, -50%)
    font-size: 80px
    line-height: 0
    background: none
    border: none
    color: white
    cursor: pointer
    transition: transform 100ms
    transform-origin: 50% 50%
    &:focus, &:hover
      transform: translate(-50%, -50%) scale(1.2)
    &:active
      transform: translate(-50%, -50%) scale(1)
</style>

<Levetate>
  <!-- svelte-ignore a11y-no-static-element-interactions -->
  <div class="controls" class:selector={selectorActive} bind:this={element} on:dblclick={openPlanetSelector} >
    <PlanetSelector on:select={onPlanetSelected} bind:active={selectorActive} />

    {#if !selectorActive}
      <div transition:fade={{ duration: 100 }} class="eclipse-slider">
        <EclipseSlider bind:progress={$eclipseProgress} on:swipe={onSwipe} on:start={seekStart} on:end={seekEnd}/>
        <button class="play-pause" on:dblclick|capture|stopPropagation on:click={togglePlay}>
          <Icon icon={ playing ? 'mdi:pause' : 'mdi:play'} />
        </button>
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