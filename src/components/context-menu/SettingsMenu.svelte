<script>
  import Toggle from '../Toggle.svelte'
  import Slider from '../Slider.svelte'
  import { totalityFactor, setQuality, qualityPreset, musicOn, showTutorial } from '../../store/environment'

  const updateQuality = (e) => {
    setQuality(e.detail.value | 0)
  }
</script>

<section class="content">
  <h2 class="heading">
    Settings
  </h2>
  <ul class="settings">
    <li>
      <h4 class="label">Gesture Hints</h4>
      <div class="switch">
        <Toggle onText="ON" offText="OFF" bind:value={$showTutorial} />
      </div>
    </li>
    <li>
      <h4 class="label">Sound</h4>
      <div class="switch">
        <Toggle onText="ON" offText="OFF" bind:value={$musicOn} />
      </div>
    </li>
    <li>
      <h4 class="label">Quality</h4>
      <div class="ctrl">
        <Slider min={1} max={4} steps={4} lowText="Low" highText="High" value={$qualityPreset} on:update={updateQuality}/>
      </div>
    </li>
    <li>
      <h4 class="label">Moon Distance (within its orbit)</h4>
      <div class="ctrl">
        <Slider min="1" max="0" lowText="Near" highText="Far" bind:value={$totalityFactor} />
      </div>
    </li>
  </ul>
</section>

<style lang="sass">
  .content
    display: flex
    flex-direction: column
    align-items: center
    color: white
    font-size: 14px
    font-weight: 400
    height: 100%
    padding: 1.5rem 0.5rem
    overflow-y: auto
    font-size: 11px
  .heading
    font-weight: 400
    margin: 0
    margin-bottom: 1em
    font-size: 11px
    text-transform: uppercase
    width: 100%
  .settings
    width: 260px
    list-style: none
    padding: 0
    margin: 0
    li
      display: flex
      flex-direction: column
      justify-content: space-between
      align-items: center
      margin: 1.5em 0
      .label
        text-transform: none
        font-size: inherit
        font-weight: 400
        width: 100%
        text-align: center
      label
        text-transform: none
        font-size: inherit
        font-weight: 400
      .switch
        width: 9.65em
      &:has(.ctrl)
        align-items: stretch
</style>