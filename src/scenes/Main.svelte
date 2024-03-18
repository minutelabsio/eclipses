<script>
  import Renderer from '../components/Renderer.svelte'
  import Camera from '../components/Camera.svelte'
  import {
    eclipseProgress,
    telescopeMode,
    transitTime,
    progressRate,
    altitude,
    planetRadius,
    atmosphereThickness,
    skyVisible,
    earthVisible,
    mountainsVisible,
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
  import { Player, Util, Tween } from 'intween'
  import { frames } from '../lib/animation'
  import { push } from 'svelte-spa-router'
  import { quintIn } from 'svelte/easing'
  import { tick } from 'svelte'

  export let selectedPlanet = 'earth'
  export let params = {}

  const delay = dt => new Promise(resolve => setTimeout(resolve, dt))

  $: params.planet ? selectedPlanet = params.planet : selectedPlanet = 'earth'

  let element
  let selectorActive = false
  const player = Player.create(1)
  let playing = !player.paused
  let cameraControls
  let hideUi = false

  $: player.totalTime = $transitTime * 1000
  // 0 will be realtime, 1 will be transitTime happens in 10 seconds
  $: player.playbackRate = Util.lerp(1, $transitTime / 10, quintIn($progressRate))

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

  const toSpace = () => {
    const tween = Tween.create({ alt: $altitude })
      .by('1s', { alt: 100 * $planetRadius }, 'expIn')

    frames(1000).pipe(tween)
      .subscribe(({ alt }) => {
        altitude.set(alt)
      })
  }

  const toPlanet = async () => {
    await tick()
    await delay(500)
    const tween = Tween.create({ alt: 100 * $planetRadius })
      .by('1s', { alt: 10 }, 'expOut')

    frames(1000).pipe(tween)
      .subscribe(({ alt }) => {
        altitude.set(alt)
      })
  }

  const openPlanetSelector = () => {
    selectorActive = true
    player.pause()
    skyVisible.set(false)
    earthVisible.set(false)
    mountainsVisible.set(false)
    // toSpace()
  }

  const onPlanetSelected = ({ detail }) => {
    const { name } = detail
    push(`/${name}`)
    skyVisible.set(true)
    earthVisible.set(true)
    mountainsVisible.set(true)
    // toPlanet()
  }

  const onSwipe = ({ detail }) => {
    // if (detail.direction === 'up') {
    //   openPlanetSelector()
    // }
  }

  const toggleTelecopeMode = async () => {
    $telescopeMode = !$telescopeMode
  }

  const toggleControls = () => {
    hideUi = !hideUi
  }

</script>
<style lang="sass">
.no-interaction
  touch-action: none
  pointer-events: none
  user-select: none
.hidden
  opacity: 0
  pointer-events: none
  user-select: none
  touch-action: none

.controls-container
  transition: filter 300ms
  &.hidden
    opacity: 1
    filter: opacity(0)
.menu-container
  position: fixed
  bottom: 0
  left: 50%
  transform: translateX(-50%)
  width: 100%
  max-width: 660px
  z-index: 101
  display: flex
  flex-direction: column
  transition: opacity 100ms

.controls
  position: fixed
  bottom: 0px
  left: 50%
  width: 100%
  max-width: 860px
  transform: translateX(-50%)
  z-index: 100
  touch-action: none

  .eclipse-slider
    position: absolute
    bottom: 62px
    left: 50%
    transform: translateX(-50%)
    height: 190px
    width: 280px
    touch-action: none
    cursor: pointer
    // box-shadow: 0 0 50px 0 hsla(0, 0%, 50%, 0.5)
    border-radius: 50%
  .planet-selector-container
    position: absolute
    bottom: 0
    left: 0
    width: 100%
    height: 280px

  .play-pause
    position: absolute
    top: 54%
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

.hide-controls
  position: fixed
  top: 0.75rem
  left: 1rem
  font-size: 24px
  button
    line-height: 0
    border: none
    padding: 0
    margin: 0
    cursor: pointer
    border-radius: 50%
    background: hsla(0, 0%, 100%, 0)
    width: 50px
    height: 50px
    color: hsla(0, 0%, 100%, .6)
    font-size: 1.5em
    transition: transform 100ms, color 150ms
    transform-origin: 50% 50%

    &:focus, &:hover
      color: hsla(0, 100%, 100%, 1)
    &:active
      color: hsla(0, 0%, 100%, .6)
    &.active
      color: hsla(0, 100%, 100%, 1)
</style>

<Levetate>
  <div class="hide-controls">
    <button on:click={toggleControls} class:active={hideUi}>
      <Icon icon="mdi:eye" />
    </button>
  </div>
  <div class="controls-container no-highlight" class:hidden={hideUi} >
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <div class="controls no-highlight" class:selector={selectorActive} bind:this={element}>
      <div class="planet-selector-container" class:no-interaction={!selectorActive}>
        <PlanetSelector on:select={onPlanetSelected} bind:active={selectorActive} bind:selected={selectedPlanet} />
      </div>

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
    <div class:hidden={selectorActive} class="menu-container no-highlight">
      <Menu
        on:planet={openPlanetSelector}
        on:telescope={toggleTelecopeMode}
      />
    </div>
  </div>
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