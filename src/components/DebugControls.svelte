<script>
  import { onMount } from 'svelte'
  import GUI from 'lil-gui'
  import {
    planetRadius,
    sunPosition,
    moonRadius,
    moonPeriapsis,
    getDatGuiState,
    altitude,
    load,
  } from '../store/environment'
  import {
    DEG,
  } from '../lib/units'
  import * as PlanetConfigs from '../configs'

  export let cameraControls

  const lookAtSun = () => {
    const [x, y, z] = $sunPosition
    cameraControls.lookInDirectionOf(x, y, z, true)
  }

  const lookAtPlanet = () => {
    cameraControls.lookInDirectionOf(0, -$planetRadius, 0, true)
  }

  const eclipseState = {
    planet: 'earth',
    lockApparentSize: false,
    // scale factor
    altitude: Math.log(($altitude + 1) / 5) / Math.log($planetRadius),

    lookAtSun: lookAtSun,
    lookAtPlanet: lookAtPlanet,
  }

  const apparentSize = (r, d) => {
    return 2 * Math.asin(r / d) * DEG
  }

  let lastApparentSize = apparentSize($moonRadius, $moonPeriapsis)

  const setAltitude = (f, Rp) => {
    const alt = (5 * Math.pow(Rp, f) - 1)
    altitude.set(alt)
  }

  onMount(() => {

    load(PlanetConfigs.earth)
    const state = getDatGuiState()
    const appSettings = new GUI({
      width: 400
    })
    const planetFolder = appSettings.addFolder('Planet')
    let moonSelector = planetFolder.add(state, 'selectedMoon', ['luna']).onChange((v) => {
      load(PlanetConfigs[eclipseState.planet].moons[v])
      appSettings.controllersRecursive().forEach(c => c.updateDisplay())
    }).listen()
    planetFolder.add(eclipseState, 'planet', [
      // 'venus',
      'earth',
      'mars',
      'jupiter',
      'saturn',
      'uranus',
      'neptune',
    ]).onChange((v) => {
      const moons = Object.keys(PlanetConfigs[v].moons)
      moonSelector = moonSelector.options(moons).onChange((v) => {
        load(PlanetConfigs[eclipseState.planet].moons[v])
        appSettings.controllersRecursive().forEach(c => c.updateDisplay())
      }).listen()
      state.selectedMoon = moons[0]
      load(PlanetConfigs[v])
      load(PlanetConfigs[v].moons[moons[0]])
      setAltitude(eclipseState.altitude, $planetRadius)
      appSettings.controllersRecursive().forEach(c => c.updateDisplay())
    })
    const perspectiveSettings = appSettings.addFolder('Perspective')
    perspectiveSettings.add(state, 'FOV', 1, 180, 1)
    perspectiveSettings.add(state, 'exposure', 0.01, 10, 0.01)
    perspectiveSettings.add(state, 'bloomIntensity', 0, 50, 0.01)
    perspectiveSettings.add(eclipseState, 'altitude', 0.2, 1, 0.001).onChange(v => {
      setAltitude(v, $planetRadius)
    })
    perspectiveSettings.add(eclipseState, 'lookAtSun')
    perspectiveSettings.add(eclipseState, 'lookAtPlanet')

    const eclipseSettings = appSettings.addFolder('Eclipse')
    eclipseSettings.add(state, 'doAnimation')
    eclipseSettings.add(state, 'eclipseProgress', 0, 1, 0.01)
    eclipseSettings.add(state, 'totalityFactor', 0, 1, 0.01)
    eclipseSettings.add(state, 'elevation', -90, 90, 0.001)

    const planetSettings = appSettings.addFolder('Planetary')
    planetSettings.add(state, 'sunIntensity', 0, 500, 1)
    planetSettings.add(state, 'planetRadius', 1e6, 1e8, 100)
    planetSettings.add(eclipseState, 'lockApparentSize').onChange(v => {
      if (v){
        lastApparentSize = apparentSize($moonRadius, $moonPeriapsis)
      }
    }).name('Lock Size at Periapsis')
    const moonRadiusCtrl = planetSettings.add(state, 'moonRadius', 1e2, 2e9, 100)
    const moonPeriapsisCtrl = planetSettings.add(state, 'moonPeriapsis', 1e6, 1e10, 100)
    planetSettings.add(state, 'moonApoapsis', 1e7, 1e10, 100)

    const atmosSettings = appSettings.addFolder('Atmosphere')
    atmosSettings.add(state, 'atmosphereThickness', 0, 1000000, 1)
    atmosSettings.add(state, 'airIndexRefraction', 1, 1.004, 0.001)
    atmosSettings.add(state, 'airSurfacePressure', 0, 200000, 1)
    atmosSettings.add(state, 'airSurfaceTemperature', 0, 1000, 1)

    const rayleighSettings = atmosSettings.addFolder('Rayleigh')
    rayleighSettings.add(state, 'overrideRayleigh')
    rayleighSettings.add(state, 'rayleighRed', 0, 40, 0.1)
    rayleighSettings.add(state, 'rayleighGreen', 0, 40, 0.1)
    rayleighSettings.add(state, 'rayleighBlue', 0, 40, 0.1)
    rayleighSettings.add(state, 'rayleighScaleHeight', 0, 100000, 10)

    const mieSettings = atmosSettings.addFolder('Mie')
    mieSettings.add(state, 'mieRed', 0, 40, 0.1)
    mieSettings.add(state, 'mieGreen', 0, 40, 0.1)
    mieSettings.add(state, 'mieBlue', 0, 40, 0.1)
    mieSettings.add(state, 'mieScaleHeight', 0, 10000, 10)
    mieSettings.add(state, 'mieAmount', 0, 1e-4, 1e-10)
    mieSettings.add(state, 'mieWavelengthRed', 0, 1, 1e-2)
    mieSettings.add(state, 'mieWavelengthGreen', 0, 1, 1e-2)
    mieSettings.add(state, 'mieWavelengthBlue', 0, 1, 1e-2)
    mieSettings.add(state, 'mieDirectional', -.999, .999, 0.000001)

    const cloudSettings = atmosSettings.addFolder('Clouds')
    cloudSettings.add(state, 'cloudZ', 0.01, 0.9, 0.01)
    cloudSettings.add(state, 'cloudThickness', 0, 20, 0.1)
    cloudSettings.add(state, 'cloudSize', 0, 10, 0.1)
    cloudSettings.add(state, 'cloudMie', 0, .999, 1e-7)
    cloudSettings.add(state, 'cloudThreshold', 0, 1, 0.01)
    cloudSettings.add(state, 'cloudAbsorption', 0, 1, 0.01)
    cloudSettings.add(state, 'windSpeed', 0, 200, 1)

    const performanceSettings = atmosSettings.addFolder('performance').close()
    performanceSettings.add(state, 'iSteps', 1, 32, 1).listen()
    performanceSettings.add(state, 'jSteps', 1, 32, 1).listen()

    const visibilitySettings = appSettings.addFolder('Visibility').close()
    visibilitySettings.add(state, 'skyVisible')
    visibilitySettings.add(state, 'starsVisible')
    visibilitySettings.add(state, 'mountainsVisible')
    visibilitySettings.add(state, 'earthVisible')

    moonRadiusCtrl.onChange(r => {
      if (eclipseState.lockApparentSize){
        $moonPeriapsis = (r / Math.sin(lastApparentSize / 2 / DEG))
        moonPeriapsisCtrl.updateDisplay()
      }
    })

    moonPeriapsisCtrl.onChange(d => {
      if (eclipseState.lockApparentSize){
        $moonRadius = d * Math.sin(lastApparentSize / 2 / DEG)
        moonRadiusCtrl.updateDisplay()
      }
    })

    return () => {
      appSettings.destroy()
    }
  })

</script>