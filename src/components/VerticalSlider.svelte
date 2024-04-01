<script>
  import Icon from '@iconify/svelte'
  import { createEventDispatcher } from 'svelte'
  export let value = 0
  export let powerScale = false
  export let icon = 'icon-park-outline:handle-round'
  export let iconPre = ''
  export let iconPost = ''
  export let min = 0.001
  export let max = 1
  export let steps = 1000

  const dispatch = createEventDispatcher()

  const lerp = (a, b, t) => a + (b - a) * t
  const invLerp = (a, b, v) => (v - a) / (b - a)
  const scale = x => powerScale ? Math.pow(100, x - 1) : x
  const invScale = x => powerScale ? 0.5 * Math.log10(x) + 1 : x

  $: sliderVal = invScale(invLerp(+min, +max, +value))
  $: step = 1 / (parseFloat(steps) - 1)
  const onChange = (e) => {
    value = lerp(+min, +max, scale(+e.target.value))
    dispatch('update', { value })
  }
</script>

<style lang="sass">
.vertical-slider
  --value: 0
  --height: 255px
  --width: 23px
  --hw: calc(var(--width) / 2)
  position: relative
  display: block
  height: var(--height)
  width: var(--width)
  input
    position: absolute
    width: var(--height)
    margin: 0
    transform-origin: var(--hw) var(--hw)
    transform: translateY(calc(var(--height) - 100%)) rotate(-90deg)
    // transform: translate(-50%, 0) rotate(-90deg)
  .icon-track
    position: absolute
    top: 0
    left: 0
    bottom: 0
    right: 0
    touch-action: none
    pointer-events: none
  .icon
    position: absolute
    bottom: 3px
    left: 50%
    color: hsla(0, 0%, 100%, 0.75)
    // color: red
    font-size: 18px
    line-height: 0
    transform: translate(-50%, calc(-1 * var(--value) * (var(--height) - 1.37em)))
    z-index: 10
    touch-action: none
    pointer-events: none
  .icon-pre,
  .icon-post
    position: absolute
    bottom: 3px
    left: 50%
    color: hsla(0, 0%, 100%, 1)
    font-size: 18px
    line-height: 0
    transform: translate(-50%, 0)
    z-index: -1
    touch-action: none
    pointer-events: none
  .icon-pre
    bottom: auto
    top: 3px
</style>

<label class="vertical-slider track-slider" style:--value={`${sliderVal}`}>
  <input class="slider" type="range" min="0" max="1" step={step} value={sliderVal} on:input={onChange} />
  <div class="icon-track">
    <div class="icon">
      <Icon icon={icon} />
    </div>
    {#if iconPre}
    <div class="icon-pre">
      <Icon icon={iconPre} />
    </div>
    {/if}
    {#if iconPost}
    <div class="icon-post">
      <Icon icon={iconPost} />
    </div>
    {/if}
  </div>
</label>