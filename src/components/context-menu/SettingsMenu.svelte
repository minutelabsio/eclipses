<script>
  import Toggle from './Toggle.svelte'
  import { totalityFactor } from '../../store/environment'

</script>

<section class="about">
  <h2 class="heading">
    Settings
  </h2>
  <ul class="settings">
    <li>
      <label for="resolution">Resolution</label>
      <Toggle onText="HI" offText="LO" />
    </li>
    <li>
      <label for="sound">Sound</label>
      <Toggle onText="ON" offText="OFF" />
    </li>
    <li>
      <h4 class="heading">Moon Distance</h4>
      <div class="ctrl">
        <label for="moon-dist">Far</label>
        <input class="slider" name="moon-dist" type="range" min="0" max="1" step="0.01" bind:value={$totalityFactor} />
        <label for="moon-dist">Near</label>
      </div>
    </li>
  </ul>
</section>

<style lang="sass">
  .about
    display: flex
    flex-direction: column
    align-items: center
    color: white
    font-size: 14px
    font-weight: 400
    height: 100%
    padding: 1.5rem 0.5rem
    overflow-y: auto
  .heading
    font-size: 10px
    font-weight: 400
    margin: 0
    margin-bottom: 1em
    text-align: center
    text-transform: uppercase
  .settings
    width: 260px
    list-style: none
    padding: 0
    margin: 0
    li
      display: flex
      justify-content: space-between
      align-items: center
      height: 40px
      margin: 0.5rem 0
      label
        text-transform: none
        font-size: inherit
        font-weight: 400
        margin-right: 0.5rem
      &:has(.ctrl)
        margin-top: 1rem
        flex-direction: column
        align-items: stretch
        .ctrl
          display: flex
          align-items: center
          justify-content: center
    .slider
      margin: 0 6px
</style>