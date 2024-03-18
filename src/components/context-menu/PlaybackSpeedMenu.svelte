<script>
  import Icon from '@iconify/svelte'
  import { progressRate } from '../../store/environment'
</script>

<div class="menu">
  <label for="speed">
    <Icon icon='mdi:tortoise'/>
  </label>
  <input class="slider" name="speed" type="range" min="0" max="1" step="0.1" bind:value={$progressRate} />
  <label for="speed">
    <Icon icon='mdi:hare'/>
  </label>
</div>

<style lang="sass">
  .menu
    display: flex
    align-items: center
    justify-content: center
  .slider
    margin: 0 6px
  label
    display: flex
    font-size: 32px
</style>