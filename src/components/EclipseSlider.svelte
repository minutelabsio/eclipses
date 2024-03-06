<script>
  import { onMount, createEventDispatcher } from 'svelte'
  import interact from 'interactjs'

  const dispatch = createEventDispatcher()

  export let progress = 0
  let element
  let dragging = false

  const setSlider = (e) => {
    if (dragging) { return }
    dispatch('start')
    const x = e.offsetX
    const y = e.offsetY
    const width = element.clientWidth
    const angle = Math.atan2(width / 2 - y, width / 2 - x)
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

  const checkClick = (e) => {
    if (dragging) { return }
    dispatch('click', e)
  }

</script>

<div bind:this={element} on:click={checkClick}>
  <svg viewBox="-10 -10 120 120">
    <!-- a semicircle -->
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <g on:click|capture|stopPropagation={setSlider} on:pointerdown|capture={setSlider}>
      <path class="path" d="M 0 50 A 50 50 0 0 1 100 50" />
      <path d="M 0 50 A 50 50 0 0 1 100 50" stroke="transparent" stroke-width="10" fill="none" />
      <!-- moon -->
      <circle
        class="moon"
        transform={`rotate(${progress * 180} 50 50)`}
        cx="0" cy="50" dx="50" r="5"
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
    stroke-width: 1px
    stroke-linecap: round
    stroke: hsla(0, 0%, 100%, 0.5)
    fill: none
  .moon
    fill: hsla(0, 0%, 50%, 1)
  //   transition: transform 0.25s ease
</style>