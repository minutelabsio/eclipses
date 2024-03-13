<script>
  import Renderer from '../components/Renderer.svelte'
  import Camera from '../components/Camera.svelte'
  import {
    AU,
  } from '../lib/units'
  import Space from './Space.svelte'
  import DebugControls from '../components/DebugControls.svelte'
  import Stats from '../components/Stats.svelte'

  let cameraControls
</script>

<DebugControls cameraControls={cameraControls}/>
<Renderer/>
<Stats />
<Space/>

<Camera
  makeDefault
  near={1}
  far={1.2 * AU}
  bind:controls={cameraControls}
/>