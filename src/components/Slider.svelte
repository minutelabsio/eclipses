<script>
  import { createEventDispatcher } from 'svelte'

  export let value = 0
  export let min = 0
  export let max = 1
  export let steps = 100
  export let lowText = 'LOW'
  export let highText = 'HIGH'

  const dispatch = createEventDispatcher()

  const lerp = (a, b, t) => a + (b - a) * t
  const invLerp = (a, b, v) => (v - a) / (b - a)

  $: sliderVal = invLerp(+min, +max, +value)
  $: step = 1 / (parseFloat(steps) - 1)
  const onChange = (e) => {
    value = lerp(+min, +max, +e.target.value)
    dispatch('update', { value })
  }
</script>

<style lang="sass">
.slider
  display: flex
  align-items: center
  justify-content: center
  font-weight: 400
  font-size: 12px
  input
    margin: 0 6px
</style>

<label class="slider">
  <span>{lowText}</span>
  <input class="slider" type="range" min="0" max="1" step={step} value={sliderVal} on:input={onChange} />
  <span>{highText}</span>
</label>