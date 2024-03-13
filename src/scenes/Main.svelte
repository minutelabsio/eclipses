<script>
  import Renderer from '../components/Renderer.svelte'
  import Camera from '../components/Camera.svelte'
  import {
    eclipseProgress,
    load,
    planet,
    sunPosition,
    telescopeMode,
  } from '../store/environment'
  import {
    AU,
  } from '../lib/units'
  import Levetate from '../components/Levetate.svelte'
  import PlanetSelector from '../components/PlanetSelector.svelte'
  import Menu from '../components/Menu.svelte'
  import Space from './Space.svelte'
  import EclipseSlider from '../components/EclipseSlider.svelte'
  import { fade } from 'svelte/transition'
  import Icon from '@iconify/svelte'
  import { Player } from 'intween'
  import { push } from 'svelte-spa-router'

  export let selectedPlanet = 'earth'
  export let params = {}

  $: params.planet ? selectedPlanet = params.planet : selectedPlanet = 'earth'

  let element
  let selectorActive = false
  const player = Player.create(10000)
  let playing = !player.paused
  let cameraControls

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
    player.pause()
  }

  const onPlanetSelected = ({ detail }) => {
    const { name } = detail
    push(`/${name}`)
  }

  const onSwipe = ({ detail }) => {
    if (detail.direction === 'up') {
      openPlanetSelector()
    }
  }

  const toggleTelecopeMode = () => {
    $telescopeMode = !$telescopeMode
    if (!cameraControls) return
    if ($telescopeMode) {
      cameraControls.saveState()
      const [x, y, z] = $sunPosition
      cameraControls.lookInDirectionOf(x, y, z, false)
    } else {
      cameraControls.reset()
    }
  }

</script>
<style lang="sass">
.menu-container
  position: fixed
  bottom: 0
  left: 50%
  transform: translateX(-50%)
  width: 100%
  height: 42px
  max-width: 660px
  z-index: 101
  backdrop-filter: blur(10px)
.controls
  position: fixed
  bottom: 0px
  left: 50%
  width: 100%
  max-width: 860px
  height: 280px
  transform: translateX(-50%)
  z-index: 100
  touch-action: none
  cursor: pointer
  overflow: hidden

  .eclipse-slider
    position: absolute
    bottom: -33%
    left: 50%
    transform: translateX(-50%)
    height: 280px
    width: 280px
    touch-action: none
    cursor: pointer
    // box-shadow: 0 0 50px 0 hsla(0, 0%, 50%, 0.5)
    border-radius: 50%

  .play-pause
    position: absolute
    top: 37%
    left: 50%
    transform: translate(-50%, -50%)
    font-size: 60px
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
  <div class="controls no-highlight" class:selector={selectorActive} bind:this={element} on:dblclick={openPlanetSelector} >
    <PlanetSelector on:select={onPlanetSelected} bind:active={selectorActive} bind:selected={selectedPlanet} />

    {#if !selectorActive}
      <div transition:fade={{ duration: 100 }} class="eclipse-slider no-highlight">
        <EclipseSlider bind:progress={$eclipseProgress} on:swipe={onSwipe} on:start={seekStart} on:end={seekEnd}>
          <button class="play-pause" on:dblclick|capture|stopPropagation on:click={togglePlay}>
            <Icon icon={ playing ? 'mdi:pause' : 'mdi:play'} />
          </button>
        </EclipseSlider>
      </div>
    {/if}
  </div>
  {#if !selectorActive}
  <div transition:fade={{ duration: 100 }} class="menu-container no-highlight">
    <Menu
      on:planet={openPlanetSelector}
      on:telescope={toggleTelecopeMode}
    />
  </div>
  {/if}
</Levetate>

<Renderer/>
<Space/>

<Camera
  makeDefault
  near={1}
  far={1.2 * AU}
  bind:controls={cameraControls}
  telescope={$telescopeMode}
/>