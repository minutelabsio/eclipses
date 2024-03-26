<script>
  import Toggle from '../Toggle.svelte'
  import Slider from '../Slider.svelte'
  import { totalityFactor, setQuality, qualityPreset } from '../../store/environment'

  const updateQuality = (e) => {
    setQuality(e.detail.value | 0)
  }
</script>

<section class="about">
  <h2 class="heading">
    Settings
  </h2>
  <ul class="settings">
    <li>
      <label for="sound">Sound</label>
      <Toggle onText="ON" offText="OFF" />
    </li>
    <li>
      <h4 class="heading">Quality</h4>
      <div class="ctrl">
        <Slider min={1} max={4} steps={4} lowText="Low" highText="High" value={$qualityPreset} on:update={updateQuality}/>
      </div>
    </li>
    <li>
      <h4 class="heading">Moon Distance (within its orbit)</h4>
      <div class="ctrl">
        <Slider min="1" max="0" lowText="Near" highText="Far" bind:value={$totalityFactor} />
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
      margin: 1.5em 0
      label
        text-transform: none
        font-size: inherit
        font-weight: 400
        margin-right: 0.5rem
      &:has(.ctrl)
        flex-direction: column
        align-items: stretch
</style>