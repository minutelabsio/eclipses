<script>
  import { elevationMid } from "../../store/environment"
</script>

<div class="time-of-day-menu">
  <label for="elevation">dawn</label>
  <input class="slider" name="elevation" type="range" min="-10" max="90" step="0.1" bind:value={$elevationMid} />
  <label for="elevation">noon</label>
</div>

<style lang="sass">
  .time-of-day-menu
    display: flex
    align-items: center
    justify-content: center

  .slider
    margin: 0 6px
  label
    display: flex
</style>