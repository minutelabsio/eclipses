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
    sunPosition,
    skyVisible,
    earthVisible,
    mountainsVisible,
    selectedMoon,
    hasLoaded,
    elevationMid,
    telescopeModeExposure,
    showTutorial,
    totalityFactor,
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
  import { onMount, tick } from 'svelte'
  import { interactivity, onReveal, Suspense } from '@threlte/extras'
  import { T } from '@threlte/core'
  import MoonSelector from '../components/MoonSelector.svelte'
  import { get, writable } from 'svelte/store'
  import Music from '../components/Music.svelte'
  import VerticalSlider from '../components/VerticalSlider.svelte'

  export let selectedPlanet = 'earth'
  export let params = {}

  let hoveringPlanet = selectedPlanet
  let hoveringMoon = 'luna'

  const delay = dt => new Promise(resolve => setTimeout(resolve, dt))

  const updateFromParams = (params) => {
    const { planet, moon } = params
    hoveringPlanet = planet || 'earth'
    selectedPlanet = planet || 'earth'
    hoveringMoon = moon || 'luna'
    selectedMoon.set(moon || 'luna')
  }

  $: updateFromParams(params)

  let element
  let selectorActive = false
  const player = Player.create(1)
  let playing = !player.paused
  let cameraControls
  let hideUi = false

  $: player.totalTime = $transitTime * 1000
  // 0 will be realtime, 1 will be transitTime happens in 10 seconds
  $: player.playbackRate = Util.lerp(1, $transitTime / 10, quintIn($progressRate))

  const playerProgress = writable(0)

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
    if (!player.isPaused) {
      playerProgress.set(player.progress / 100)
    }
  })

  playerProgress.subscribe((v) => {
    player.progress = v * 100
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

  const lookAtSun = () => {
    const [x, y, z] = $sunPosition
    cameraControls.lookInDirectionOf(x, y, z, true)
  }

  const openPlanetSelector = () => {
    hoveringMoon = $selectedMoon
    selectorActive = true
    player.pause()
    skyVisible.set(false)
    earthVisible.set(false)
    mountainsVisible.set(false)
    // toSpace()
    $telescopeMode = false
  }

  const onPlanetSelected = ({ detail }) => {
    const { name } = detail
    push(`/${name}/${hoveringMoon}`)
    skyVisible.set(true)
    earthVisible.set(true)
    mountainsVisible.set(true)
    // toPlanet()
  }

  let selectedMenuItem
  $: hideEclipseControls = !selectorActive && ($selectedMenuItem === 'info' || $selectedMenuItem === 'settings')

  interactivity({
    filter: (hits, state) => {
      // Only return the first hit
      return hits.slice(0, 1)
    }
  })


  const animateSunrise = () => {
    const tween = Tween.create({ el: -5 })
      .by('2s', { el: -5 }, 'linear')
      .by('12s', { el: get(elevationMid) }, 'quadInOut')

    frames(12000)
      .pipe(tween)
      .subscribe(({ el }) => {
        elevationMid.set(el)
      })
  }

  onReveal(() => {
    hasLoaded.update((v) => {
      if (!v) {
        animateSunrise()
        $showTutorial = true
        delay(10000).then(() => {
          $showTutorial = false
        })
      }
      return true
    })
  })

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

.planet-moon-title, .planet-moon-selector-title
  font-family: "Plus Jakarta Sans", sans-serif
  color: hsla(0, 0%, 100%, .25)
  font-size: 25px
  h2, h3
    margin: 0
    font-weight: 400
  h2
    font-size: 1em
    &::first-letter
      text-transform: uppercase
  h3
    font-size: 0.5em
    letter-spacing: 0.6px
    margin-left: 0.1em
    text-transform: uppercase
.planet-moon-selector-title
  position: absolute
  bottom: 0
  left: 0
  width: 100%
  text-align: center
  h2
    position: absolute
    bottom: 0
    left: 50%
    transform: translateY(-85px) translateX(-50%)
    color: white
    font-size: 36px
    text-shadow: 0 0 5px hsla(0, 100%, 100%, 0.75)
  h3
    position: absolute
    bottom: 0
    left: 50%
    transform: translateY(-594px) translateX(-50%)
    color: hsla(0, 100%, 100%, 0.75)
    font-size: 16px
    letter-spacing: 0.8px
    text-transform: none
    &:first-letter
      text-transform: uppercase

.planet-moon-title
  position: fixed
  top: 0.9em
  left: 0.88em
  z-index: 100

.controls
  position: fixed
  bottom: 0px
  left: 50%
  width: 100%
  max-width: 860px
  transform: translateX(-50%)
  z-index: 100
  touch-action: none
  &.hidden
    opacity: 1
    filter: opacity(0)

  .eclipse-slider
    position: absolute
    bottom: 48px
    left: 50%
    transform: translateX(-50%)
    height: 184px
    width: 270px
    touch-action: none
    cursor: pointer
    // box-shadow: 0 0 50px 0 hsla(0, 0%, 50%, 0.5)
    border-radius: 50%
  .planet-selector-container
    position: absolute
    bottom: 0
    left: 0
    width: 100%
    height: 340px
  .moon-selector-container
    position: absolute
    bottom: 450px
    left: 50%
    transform: translateX(-50%)
    max-width: 660px
    transition: opacity 100ms
    width: 100%
    &::after
      content: ''
      position: absolute
      top: 95px
      left: 50%
      transform: translateX(-50%)
      width: 800px
      height: 800px
      border: 1px solid hsla(0, 0%, 100%, 0.2)
      border-radius: 50%
      z-index: -1
      pointer-events: none
      touch-action: none

  .play-pause
    position: absolute
    top: 54%
    left: 50%
    transform: translate(-50%, -50%)
    font-size: 60px
    line-height: 0
    background: none
    border: none
    color: hsla(0, 0%, 100%, .7)
    cursor: pointer
    transition: transform 100ms
    transform-origin: 50% 50%
    &:focus, &:hover
      color: hsla(0, 100%, 100%, 1)
    &:hover
      transform: translate(-50%, -50%) scale(1.1)
    &:active
      color: hsla(0, 0%, 100%, .7)
      transform: translate(-50%, -50%) scale(1)

.hide-controls
  position: fixed
  top: 1.2em
  right: 0.88em
  font-size: 25px
  button
    font-size: 38px
    line-height: 0
    border: none
    padding: 0
    margin: 0
    cursor: pointer
    border-radius: 50%
    background: hsla(0, 0%, 100%, 0)
    color: hsla(0, 0%, 100%, .4)
    transition: transform 100ms, color 150ms
    transform-origin: 50% 50%

    &:focus, &:hover
      color: hsla(0, 100%, 100%, 1)
    &:active
      color: hsla(0, 0%, 100%, .7)
    &.active
      color: hsla(0, 100%, 100%, .8)

@media screen and (min-width: 1024px)
  .planet-moon-title,
  .planet-moon-selector-title,
  .hide-controls
    font-size: 48px

.brand
  position: fixed
  bottom: 31px
  left: 50%
  transform: translateX(-50%)
  text-align: center
  color: #FFF
  text-align: center
  font-family: 'latin-modern-mono', monospace
  font-size: 9px
  font-weight: 400
  letter-spacing: 0.45px
  color: hsla(0, 0%, 60%, 0.8)

.tutorial
  position: fixed
  font-family: 'Plus Jakarta Sans', sans-serif
  top: 160px
  left: 50%
  padding: 1em
  transform: translateX(-50%)
  font-size: 18px
  font-weight: 400
  color: hsla(0, 0%, 70%, 0.8)
  text-shadow: 0 0 2px hsla(0, 100%, 0%, 0.15)
  z-index: 100
  width: 100%
  max-width: 460px
  height: 10em
  transition: opacity 1000ms
  display: flex
  justify-content: space-around
  > *
    display: flex
    flex-direction: column
    align-items: center
    justify-content: flex-end
    max-width: 3em
    text-align: center
  .icon
    font-size: 5em
    vertical-align: middle
  .gesture-text
    margin-bottom: 0.5em
    text-transform: uppercase
.exposure,
.elevation,
.moon-distance
  position: fixed
  bottom: 50%
  right: 22px
  transform: translateY(calc(50% - 60px))
  transition: transform 300ms
  &.hidden
    transform: translateY(calc(50% - 60px)) translateX(100px)
.moon-distance
  left: 22px
  right: auto
  :global(svg path)
    transform: translate(-1px, -1px)
.sliders-side
  transition: opacity 300ms
</style>

<Suspense>

  <T.Group on:dblclick={lookAtSun} on:click={() => selectorActive = false}>
    <Space/>
  </T.Group>

  <Music/>

</Suspense>

<Renderer/>

<Camera
  makeDefault
  near={1}
  far={1.2 * AU}
  bind:controls={cameraControls}
  telescope={$telescopeMode}
  animateTelescope={!playing}
/>

<Levetate>
  <aside class="tutorial no-interaction" class:hidden={!$showTutorial}>
    <div>
      <span class="gesture-text">Double Tap</span>
      <span class="icon">
        <Icon icon="mdi:gesture-double-tap" />
      </span>
      <span>Center Sun</span>
    </div>
    <div>
      <span class="gesture-text">Drag</span>
      <span class="icon">
        <Icon icon="mdi:gesture-swipe" />
      </span>
      <span>360 Pan</span>
    </div>
    <div>
      <span class="gesture-text">Pinch/ Scroll</span>
      <span class="icon">
        <Icon icon="mdi:gesture-pinch" />
      </span>
      <span>Zoom In/Out</span>
    </div>
  </aside>
  <aside class="planet-moon-title no-interaction" class:hidden={selectorActive}>
    <h2>{hoveringPlanet || ''}</h2>
    <h3>{hoveringMoon || ''}</h3>
  </aside>
  <aside class="brand" class:hidden={!hideUi}>
    MINUTELABS.io
  </aside>
  <div class="hide-controls">
    <button on:click={toggleControls} class:active={hideUi}>
      <Icon icon={hideUi ? 'material-symbols:visibility' : 'material-symbols:visibility-outline'} />
    </button>
  </div>
  <div class="controls-container no-highlight" class:hidden={hideUi} >
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <div class="controls no-highlight" class:selector={selectorActive} class:hidden={hideEclipseControls} bind:this={element}>
      <div class="planet-selector-container" class:no-interaction={!selectorActive}>
        <PlanetSelector on:select={onPlanetSelected} bind:active={selectorActive} bind:selected={selectedPlanet} bind:hovering={hoveringPlanet} />
      </div>

      <div class="moon-selector-container" class:hidden={!selectorActive}>
        <MoonSelector planet={hoveringPlanet} bind:hoveringMoon={hoveringMoon} on:select={() => selectorActive = false} />
      </div>

      <aside class="planet-moon-selector-title no-interaction" class:hidden={!selectorActive}>
        <h2>{hoveringPlanet || ''}</h2>
        <h3>{hoveringMoon || ''}</h3>
      </aside>

      {#if !selectorActive}
        <div transition:fade={{ duration: 100 }} class="eclipse-slider no-highlight">
          <EclipseSlider bind:progress={$playerProgress} on:swipe={onSwipe} on:start={seekStart} on:end={seekEnd}>
            <button class="play-pause" on:dblclick|capture|stopPropagation on:click={togglePlay}>
              <Icon icon={ playing ? 'material-symbols:pause-rounded' : 'material-symbols:play-arrow-rounded'} />
            </button>
          </EclipseSlider>
        </div>
      {/if}
    </div>
    <div class:hidden={selectorActive} class="menu-container no-highlight">
      <Menu
        bind:selected={selectedMenuItem}
        bind:telescope={$telescopeMode}
        on:planet={openPlanetSelector}
      />
    </div>
  </div>
  <div class:hidden={hideUi} style:display={selectorActive ? 'none' : 'block'} class="sliders-side">
    <div class="exposure" class:hidden={!$telescopeMode}>
      <VerticalSlider powerScale bind:value={$telescopeModeExposure} icon="ion:glasses" />
    </div>
    <div class="elevation" class:hidden={$telescopeMode}>
      <VerticalSlider bind:value={$elevationMid} icon="material-symbols-light:clear-day" iconPre="material-symbols:arrow-upward" iconPost="material-symbols:arrow-downward" min={-10} max={90} steps={1000} />
    </div>
    <div class="moon-distance">
      <VerticalSlider bind:value={$totalityFactor} icon="material-symbols-light:clear-night" iconPre="material-symbols:add" iconPost="material-symbols:remove" />
    </div>
  </div>
</Levetate>