<script>
  import { Canvas } from '@threlte/core'
  import { onMount, createEventDispatcher } from 'svelte'
  import PlanetSelectorScene from './PlanetSelectorScene.svelte'
  import interact from 'interactjs'
  import { Observable, Tween, animationFrames } from 'intween'
  import { frames } from '../lib/animation'

  const dispatch = createEventDispatcher()

  const planetNames = [
    'earth',
    'mars',
    'jupiter',
    'saturn',
    'uranus',
    'neptune'
  ]
  const MIN_FLICK_VEL = 0.8
  let element
  let pos = 0
  let scale = 500
  let planetIndex = 0
  const nplanets = 6
  const dangle = 2 * Math.PI / nplanets
  const a = 0.008 // friction

  let sub = null
  let timer = null

  const flick = v => {
    let ds = v * v / (2 * a)
    ds = Math.min(ds, 2 * Math.PI * scale)
    // min flick
    if (Math.abs(v) > MIN_FLICK_VEL) {
      ds = Math.max(ds, dangle * scale)
    }
    // get the closest planet to end position
    const x = pos + ds * Math.sign(v)
    let i = Math.round(x / dangle / scale)
    const target = dangle * scale * i

    planetIndex = (nplanets - i % nplanets) % nplanets

    const time = Math.sqrt(2 * Math.abs(target - pos) / a)
    const tween = Tween.create({ pos })
      .by(time, { pos: target }, 'quadOut')

    sub = frames(time)
      .pipe(tween)
      .subscribe((state) => {
        pos = state.pos
      })

    clearTimeout(timer)
    timer = setTimeout(() => {
      dispatch('change', {
        index: planetIndex,
        name: planetNames[planetIndex]
      })
    }, time + 500)
  }

  const moveToPlanet = (name, done) => {
    const i = planetNames.indexOf(name)
    let target = dangle * scale * (nplanets - i)
    pos = (pos + 2 * Math.PI * scale) % (2 * Math.PI * scale)
    if (pos - target > Math.PI * scale) {
      target += 2 * Math.PI * scale
    } else if (target - pos >= Math.PI * scale) {
      target -= 2 * Math.PI * scale
    }
    const time = 500
    const tween = Tween.create({ pos })
      .by(time, { pos: target }, 'quadOut')

    sub = frames(time)
      .pipe(tween)
      .subscribe((state) => {
        pos = state.pos
      }, null, done)
  }

  onMount(() => {
    const draggable = interact(element).draggable({
      listeners: {
        start(e){
          sub?.unsubscribe()
          clearTimeout(timer)
        },
        move(e){
          pos += e.dx
        },
        end(e){
          flick(e.velocity.x / 1000)
        }
      }
    })
    return () => {
      draggable.unset()
    }
  })

  const handlePlanetClicked = (e) => {
    clearTimeout(timer)
    sub?.unsubscribe()
    const { planet } = e.detail
    moveToPlanet(planet, () => {
      dispatch('change', {
        index: planetNames.indexOf(planet),
        name: planet
      })
    })
  }

</script>

<div class="planet-selector" bind:this={element}>
  <Canvas>
    <PlanetSelectorScene pos={pos / scale} on:planetClicked={handlePlanetClicked} />
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