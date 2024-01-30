import { writable, derived, get } from 'svelte/store'
import { Vector3, MathUtils } from 'three'
import {
  METER,
  Re,
  AU,
  DEG
} from '../lib/units'
import { skyPosition } from '../lib/sky-position'

export const FOV = writable(26.5)
export const exposure = writable(1.0)
export const bloomIntensity = writable(5)

export const altitude = writable(1)
export const planetRadius = writable(Re)
export const atmosphereThickness = writable(7 * 8e3)
export const elevation = writable(2)
export const elevationRad = derived(
  [elevation],
  ([$elevation]) => $elevation * DEG
)

export const sunDistance = writable(1 * AU)
export const sunRadius = writable(109 * Re)
export const sunPosition = derived(
  [sunDistance, elevationRad],
  ([$sunDistance, $elevationRad]) => skyPosition($sunDistance, $elevationRad, 0)
)

export const totalityFactor = writable(0.9)
export const moonRadius = writable(0.2727 * Re)
export const moonPerigee = writable(356500 * 1000 * METER)
export const moonApogee = writable(406700 * 1000 * METER)
export const moonOrbitInclination = writable(5.145 * DEG + 23.44 * DEG)
export const moonDec = writable(0)
export const moonDistance = derived(
  [moonPerigee, moonApogee, totalityFactor],
  ([$moonPerigee, $moonApogee, $totalityFactor]) => MathUtils.lerp($moonPerigee, $moonApogee, 1 - $totalityFactor)
)
export const moonAxis = derived(
  [moonOrbitInclination],
  ([$moonOrbitInclination]) => new Vector3(1, 0, 0).applyAxisAngle(new Vector3(0, 0, 1), $moonOrbitInclination)
)
export const moonPosition = derived(
  [moonDistance, elevationRad, moonAxis, moonDec],
  ([$moonDistance, $elevationRad, $moonAxis, $moonDec]) =>
    skyPosition($moonDistance, $elevationRad, 0, new Vector3())
      .applyAxisAngle($moonAxis, $moonDec)
)


export const sunIntensity = writable(25)
export const rayleighRed = writable(5.5e-6)
export const rayleighGreen = writable(13.0e-6)
export const rayleighBlue = writable(22.4e-6)
export const rayleighScaleHeight = writable(8e3)
export const mieCoefficient = writable(21e-6)
export const mieScaleHeight = writable(500)
export const mieDirectional = writable(-0.758)
// clouds
export const cloudZ = writable(0.2)
export const cloudThickness = writable(4)
export const cloudSize = writable(1)
export const cloudMie = writable(0.78)
export const cloudThreshold = writable(0.4)
export const windSpeed = writable(0.08)

export const iSteps = writable(6)
export const jSteps = writable(5)

// visibility
export const skyVisible = writable(true)
export const starsVisible = writable(true)
export const mountainsVisible = writable(true)
export const earthVisible = writable(true)

const state = {
  FOV,
  exposure,
  bloomIntensity,

  elevation,
  planetRadius,
  atmosphereThickness,

  sunDistance,
  sunRadius,

  totalityFactor,

  moonRadius,
  moonPerigee,
  moonApogee,

  moonOrbitInclination,
  moonDec,
  moonPosition,

  sunIntensity,

  rayleighRed,
  rayleighGreen,
  rayleighBlue,
  rayleighScaleHeight,

  mieCoefficient,
  mieScaleHeight,
  mieDirectional,

  cloudZ,
  cloudThickness,
  cloudSize,
  cloudMie,
  cloudThreshold,
  windSpeed,

  iSteps,
  jSteps,

  skyVisible,
  starsVisible,
  mountainsVisible,
  earthVisible,
}

export const getDatGuiState = () => {
  const settings = {}
  for (let key in state){
    Object.defineProperty(settings, key, {
      get(){
        return get(state[key])
      },
      set(value){
        state[key].set(value)
      }
    })
  }
  return settings
}

export function load(settings){
  for (let key in settings){
    if (key in state){
      state[key].set(settings[key])
    }
  }
}