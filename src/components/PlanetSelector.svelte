<script>
  import { Canvas } from '@threlte/core'
  import { onMount } from 'svelte'
  import PlanetSelectorScene from './PlanetSelectorScene.svelte'
  import interact from 'interactjs'
  import { Tween, animationFrames } from 'intween'
    import { planet } from '../store/environment';

  export let onChange = () => {}

  const planetNames = [
    'Earth',
    'Mars',
    'Jupiter',
    'Saturn',
    'Uranus',
    'Neptune'
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

    planetIndex = (nplanets - i) % nplanets

    const time = Math.sqrt(2 * Math.abs(target - pos) / a)
    const tween = Tween.create({ pos })
      .by(time, { pos: target }, 'quadOut')

    sub = animationFrames()
      .pipe(tween)
      .subscribe((state) => {
        pos = state.pos
      })

    clearTimeout(timer)
    timer = setTimeout(() => {
      sub?.unsubscribe()
      onChange({
        index: planetIndex,
        name: planetNames[planetIndex]
      })
    }, time + 250)
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

</script>

<div class="planet-selector" bind:this={element}>
  <Canvas>
    <PlanetSelectorScene pos={pos / scale} />
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