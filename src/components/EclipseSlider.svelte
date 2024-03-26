<script>
  import { onMount, createEventDispatcher } from 'svelte'
  import interact from 'interactjs'

  const dispatch = createEventDispatcher()

  export let progress = 0
  let pos = 0
  let element
  let dragging = false
  const range = [0.05, 0.95]

  const remap = (value, from, to) => {
    return (value - from[0]) / (from[1] - from[0]) * (to[1] - to[0]) + to[0]
  }

  $: pos = remap(progress, [0, 1], range)

  const setSlider = (e) => {
    if (dragging) { return }
    dispatch('start')
    const x = e.offsetX
    const y = e.offsetY
    const width = element.clientWidth
    let angle = Math.atan2(width / 2 - y, width / 2 - x)
    progress = angle / Math.PI
    dispatch('end')
  }

  onMount(() => {
    const int = interact(element).styleCursor(false).draggable({
      listeners: {
        start(event) {
          dragging = true
          dispatch('start')
        },
        move(event) {
          event.preventDefault()
          const width = element.clientWidth * 0.9
          progress = Math.min(1, Math.max(0, progress + event.dx / width))
        },
        end(event) {
          setTimeout(() => {
            dragging = false
            dispatch('end')
            if (event.speed > 1000) {
              let direction = event.velocity.x > 0 ? 'right' : 'left'
              direction = Math.abs(event.velocity.x) > Math.abs(event.velocity.y) ? direction : event.velocity.y > 0 ? 'down' : 'up'
              dispatch('swipe', { direction })
            }
          }, 100)
        },
      },
    })
    return () => int.unset()
  })

  const checkKey = (e) => {
    dispatch('start')
    if (e.key === 'ArrowLeft') {
      progress = Math.max(0, progress - 0.01)
    }
    if (e.key === 'ArrowRight') {
      progress = Math.min(1, progress + 0.01)
    }
    dispatch('end')
  }

  const checkClick = (e) => {
    if (dragging) { return }
    dispatch('click', e)
  }

</script>

<div bind:this={element} on:click={checkClick} on:keydown={checkKey} role="slider" aria-valuenow={progress} tabindex="0">
  <svg viewBox="-10 -10 120 120">
    <filter id="blur">
      <feGaussianBlur stdDeviation="1" />
    </filter>

    <!-- a semicircle -->
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <g on:click|capture|stopPropagation={setSlider} on:pointerdown|capture={setSlider}>
      <path class="path" d="M 0 50 A 50 50 0 0 1 100 50" />
      <path class="path before" d="M 0 50 A 50 50 0 0 1 100 50" stroke-dasharray={`${6 + progress * Math.PI * 50 * (range[1] - range[0])} 314`}/>

      <circle
        class="shadow"
        transform={`rotate(${pos * 180} 50 50)`}
        cx="14" cy="50" r="4.5"
        fill="black"
        filter="url(#blur)"
      />
      <!-- moon -->
      <circle
        class="moon"
        transform={`rotate(${pos * 180} 50 50)`}
        cx="0" cy="50" dx="50" r="4.5"
      />
    </g>
    <!-- a circle -->
    <!-- <circle cx="50" cy="50" r="10" fill="white" /> -->
  </svg>
  <slot/>
</div>

<style lang="sass">
  svg
    outline: none
  // stroke inside the semicircle
  .path
    stroke-width: 9px
    stroke-linecap: round
    // stroke: hsla(0, 0%, 100%, 0.1)
    stroke: hsla(0, 0%, 30%, 0.8)
    fill: none
  .before
    stroke: hsla(0, 0%, 60%, .95)
  .moon
    fill: #AEAEAE
    stroke-width: .8
    stroke: white
  .shadow
    fill: hsla(0, 0%, 0%, .6)
</style>