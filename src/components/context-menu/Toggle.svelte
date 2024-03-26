<script>
  import Icon from '@iconify/svelte'

  export let value = false
  export let onText = 'on'
  export let offText = 'off'
</script>

<style lang="sass">
.toggle
  display: flex
  align-items: center
  justify-content: center
  cursor: pointer
  font-size: inherit
  width: 100px

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

  .off
    display: inline-block

  input[type='checkbox']:checked ~ .on
    display: inline-block
  input[type='checkbox']:checked ~ .off
    display: none
</style>

<label class="toggle">
  <span>{onText}</span>
  <input type="checkbox" bind:checked={value} />
  <span class="on">
    <Icon icon="material-symbols:toggle-on-outline" />
  </span>
  <span class="off">
    <Icon icon="material-symbols:toggle-off-outline" />
  </span>
  <span>{offText}</span>
</label>