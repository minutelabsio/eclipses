<script>
  import Icon from '@iconify/svelte'
  import { createEventDispatcher } from 'svelte'
  export let value = 0
  export let min = 0.001
  export let max = 1
  export let steps = 1000

  const dispatch = createEventDispatcher()

  const lerp = (a, b, t) => a + (b - a) * t
  const invLerp = (a, b, v) => (v - a) / (b - a)
  const scale = x => Math.pow(100, x - 1)
  const invScale = x => 0.5 * Math.log10(x) + 1

  $: sliderVal = invScale(invLerp(+min, +max, +value))
  $: step = 1 / (parseFloat(steps) - 1)
  const onChange = (e) => {
    value = lerp(+min, +max, scale(+e.target.value))
    dispatch('update', { value })
  }
</script>

<style lang="sass">
.exposure-slider
  --value: 0
  --width: 228px
  position: relative
  display: block
  width: var(--width)
  input
    position: relative
    right: 14px
    width: 100%
    transform: translate(50%, 0) rotate(-90deg)
  .icon-track
    position: absolute
    top: 0
    left: 0
    bottom: 0
    right: 0
    touch-action: none
    pointer-events: none
    transform: translate(50%, 0) rotate(-90deg)
  .icon
    position: absolute
    top: 2px
    left: 3px
    color: hsla(0, 0%, 50%, 1)
    // color: red
    font-size: 18px
    transform: translateX(calc(var(--value) * (var(--width) - 28px))) rotate(90deg)
    z-index: 1
    touch-action: none
    pointer-events: none
</style>

<label class="exposure-slider" style:--value={`${sliderVal}`}>
  <input class="slider" type="range" min="0" max="1" step={step} value={sliderVal} on:input={onChange} />
  <div class="icon-track">
    <div class="icon">
      <Icon icon="ion:glasses" />
    </div>
  </div>
</label>