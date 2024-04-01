<script>
  import Icon from '@iconify/svelte'
  import { progressRate } from '../../store/environment'
</script>

<div class="menu track-slider-thick">
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
    position: relative
    display: flex
    align-items: center
    justify-content: center
    width: 265px
    margin: auto
  .slider
    margin: 0 6px
  label
    display: flex
    position: absolute
    z-index: -1
    font-size: 22px
    color: white
    top: 50%
    left: 0.5em
    transform: translateY(-50%)
  label:last-child
    left: auto
    right: 0.5em
</style>