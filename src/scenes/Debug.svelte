<script>
  import Renderer from '../components/Renderer.svelte'
  import Camera from '../components/Camera.svelte'
  import {
    AU,
  } from '../lib/units'
  import Space from './Space.svelte'
  import DebugControls from '../components/DebugControls.svelte'
  import Stats from '../components/Stats.svelte'
  import Levetate from '../components/Levetate.svelte'
  import { filedrop } from 'filedrop-svelte'
  import { LUT3dlLoader } from 'three/addons/loaders/LUT3dlLoader.js'
  import { LUTImageLoader } from 'three/addons/loaders/LUTImageLoader.js'
  import { orbitPlanet } from '../store/environment'

  let cameraControls
  let useLutPre = true
  let useLutPost = true
  let lutPreFilename = 'none'
  let lutPostFilename = 'none'
  let lutPre = null
  let lutPost = null
  const lutLoader = new LUT3dlLoader()
  const lutImageLoader = new LUTImageLoader()

  const handleDrop = (which) => (e) => {
    const file = e.detail.files.accepted[0]
    if (which === 'pre') {
      lutPreFilename = file.name
    } else {
      lutPostFilename = file.name
    }
    const dataUrl = URL.createObjectURL(file)
    const loader = file.name.endsWith('.3dl') ? lutLoader : lutImageLoader
    loader.load(dataUrl, ({ texture3D }) => {
      if (which === 'pre') {
        lutPre = texture3D
      } else {
        lutPost = texture3D
      }
    }, null, (e) => {
      console.error(e)
      if (which === 'pre') {
        lutPre = false
        lutPreFilename = 'none'
      } else {
        lutPost = false
        lutPostFilename = 'none'
      }
    })
  }

</script>

<DebugControls cameraControls={cameraControls}/>
<Renderer lutPre={useLutPre && lutPre} lutPost={useLutPost && lutPost}/>
<Stats />
<Space/>

<Levetate>
<div class="lut-upload">
  <p>
    LUT Pre: ({lutPreFilename})
    <input type="checkbox" checked on:change={(e) => { useLutPre = e.target.checked }}/>
    <span class="filedrop" on:filedrop={handleDrop('pre')} use:filedrop={{windowDrop: false}}>
      Drop LUT file here
    </span>
  </p>
  <p>
    LUT Post: ({lutPostFilename})
    <input type="checkbox" checked on:change={(e) => { useLutPost = e.target.checked }}/>
    <span class="filedrop" on:filedrop={handleDrop('post')} use:filedrop={{windowDrop: false}}>
      Drop LUT file here
    </span>
  </p>
</div>
</Levetate>

<Camera
  makeDefault
  near={1}
  far={1.2 * AU}
  orbitPlanet={$orbitPlanet}
  bind:controls={cameraControls}
/>

<style lang="sass">
  .lut-upload
    position: absolute
    bottom: 0
    left: 0
    right: 400px
    padding: 20px
    background: rgba(255, 255, 255, 0.1)
    display: flex
    flex-direction: row
    justify-content: space-around
  .filedrop
    padding: 2rem
    background: rgba(255, 255, 255, 0.1)
    cursor: pointer
    &:hover
      background: rgba(255, 255, 255, 0.3)
</style>