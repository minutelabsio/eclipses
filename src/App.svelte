<script>
  import { Canvas, T } from '@threlte/core'
  import Main from './scenes/Main.svelte'
  import Fisheye from './scenes/Fisheye.svelte'
  import Router, { replace } from 'svelte-spa-router'
  import { wrap } from 'svelte-spa-router/wrap'
  import { onMount } from 'svelte'
  import { NoToneMapping } from 'three'
  import { Suspense } from '@threlte/extras'
  import Visualizer from './scenes/Visualizer.svelte'
  import Levetate from './components/Levetate.svelte'
  import Debug from './scenes/Debug.svelte'
  import { selectPlanet, dpr, fogHue, sunBrightness } from './store/environment'
  import * as PlanetConfigs from './configs'
  import { sineIn } from 'svelte/easing'
  import { GoogleAnalytics } from '@beyonk/svelte-google-analytics'
  import { ga } from '@beyonk/svelte-google-analytics'

  const routes = {
    '/fisheye': Fisheye,
    '/debug': Debug,
    '/vis': Visualizer,
    '/:planet/:moon?': wrap({
      component: Main,
      conditions: [
        (detail) => {
          const { planet } = detail.params
          if (!planet || !PlanetConfigs[planet]) {
            return false
          }
          return true
        }
      ]
    }),
    '*': Main,
  }

  const defaultToEarth = () => {
    replace('/earth')
  }

  function routeLoaded(e){
    const { params } = e.detail
    if (!params) return
    const planet = params.planet
    const moon = params.moon
    selectPlanet(planet, moon)

    if (planet){
      ga.addEvent('select_planet', {
        planet: planet,
        moon: moon,
      })
    }
  }

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

  let fog
  $: fog?.color.setHSL($fogHue / 360, .2, sineIn($sunBrightness) * 0.1)
</script>

<main>
  <Canvas
    useLegacyLights={false}
    rendererParameters={renderOptions}
    toneMapping={NoToneMapping}
    dpr={$dpr}
  >
    <Suspense>
      <Levetate slot="fallback">
        <div class="loading">loading...</div>
      </Levetate>
      <Router {routes} on:routeLoaded={routeLoaded} on:conditionsFailed={defaultToEarth}/>
    </Suspense>

    <T.FogExp2 attach="fog" bind:ref={fog} density={1.5e-5} layers={9}/>

  </Canvas>
  {#if import.meta.env.PROD}
    <GoogleAnalytics
      properties={[ import.meta.env.VITE_GA_ID ]}
    />
  {/if}
</main>

<style lang="sass">
  main
    background: black
    display: flex
    flex-grow: 1
    flex: 1
    max-height: 100vh
    overflow: hidden
  .loading
    position: absolute
    top: 50%
    left: 50%
    font-family: 'Plus Jakarta Sans', sans-serif
    transform: translate(-50%, -50%)
    color: hsla(0, 0%, 80%, 0.7)
    font-size: 2rem
    z-index: 100
    -webkit-user-select: none
    -moz-user-select: none
    -ms-user-select: none
    -o-user-select: none
    -khtml-user-select: none
    -webkit-touch-callout: none
    pointer-events: none
    user-select: none
</style>
