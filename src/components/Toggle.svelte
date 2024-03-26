<script>
  import { createEventDispatcher } from 'svelte'
  import Icon from '@iconify/svelte'

  export let value = false
  export let onText = 'on'
  export let offText = 'off'

  const dispatch = createEventDispatcher()

  const onChange = (e) => {
    dispatch('update', { value })
  }
</script>

<style lang="sass">
.toggle
  display: flex
  align-items: center
  justify-content: center
  cursor: pointer
  font-size: inherit
  width: 100px
  height: 1.2em

  > *
    margin: 0 0.2rem

  input[type='checkbox']
    -webkit-appearance: none
    appearance: none
    background-color: transparent
    margin: 0

  .on, .off
    display: none
    font-size: 40px
    line-height: 0
    height: 100%
    align-items: center

  .off
    display: flex
    color: hsla(0, 0%, 100%, 0.5)

  input[type='checkbox']:checked ~ .on
    display: flex
  input[type='checkbox']:checked ~ .off
    display: none
</style>

<label class="toggle">
  <span>{offText}</span>
  <input type="checkbox" bind:checked={value} on:change={onChange} />
  <span class="on">
    <Icon icon="material-symbols:toggle-on-outline" />
  </span>
  <span class="off">
    <Icon icon="material-symbols:toggle-off-outline" />
  </span>
  <span>{onText}</span>
</label>