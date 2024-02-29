<script>
  import { Canvas } from '@threlte/core'
  import Space from './scenes/Space.svelte'
  import Test from './scenes/Test.svelte'
  import { Router } from 'svelte-router-spa'
  import { onMount } from 'svelte'
  import { NoToneMapping } from 'three'
  import { Suspense, HTML, Billboard } from '@threlte/extras'
  import Visualizer from './scenes/Visualizer.svelte'

  const routes = [
    { name: '/', component: Space },
    { name: '/sky', component: Test },
    { name: '/vis', component: Visualizer }
  ]

  const renderOptions = {
    powerPreference: 'high-performance',
    antialias: false,
    stencil: false,
    depth: false,
    alpha: false,
    logarithmicDepthBuffer: true,
  }

  onMount(() => {
    // remove the .ml-spinner element
    document.querySelector('.ml-spinner')?.remove()
  })
</script>

<main>
  <Canvas
    useLegacyLights={false}
    rendererParameters={renderOptions}
    toneMapping={NoToneMapping}
    dpr={1}
  >
    <Suspense>
      <Billboard slot="fallback">
        <HTML>
          <div class="loading">loading...</div>
        </HTML>
      </Billboard>
      <Router {routes} />
    </Suspense>
    <!-- <Test /> -->
  </Canvas>

</main>

<style lang="sass">
  main
    background: black
    display: flex
    flex-grow: 1
    flex: 1
  .loading
    position: absolute
    top: 50%
    left: 50%
    transform: translate(-50%, -50%)
    color: white
    font-size: 2rem
    font-weight: bold
    text-shadow: 0 0 10px black
    z-index: 100
    pointer-events: none
    user-select: none
    -webkit-user-select: none
    -moz-user-select: none
    -ms-user-select: none
    -o-user-select: none
    -khtml-user-select: none
    -webkit-touch-callout: none
</style>
