import { writable, derived, get } from 'svelte/store'
import { Vector3, MathUtils } from 'three'
import {
  METER,
  Re,
  AU,
  DEG
} from '../lib/units'
import { skyPosition } from '../lib/sky-position'

const sphereIntersection = (origin, ray, radius) => {
  const b = ray.dot(origin)
  const c = origin.dot(origin) - radius * radius
  const d = b * b - c
  if (d < 0) {
    return null
  }
  const sqrtd = Math.sqrt(d)
  const x0 = -b - sqrtd
  const x1 = -b + sqrtd
  return x0 < x1 ? [x0, x1] : [x1, x0]
}

export const FOV = writable(26.5)
export const exposure = writable(1.0)
export const bloomIntensity = writable(5)

export const altitude = writable(400)
export const fogHue = writable(200)
export const eclipseProgress = writable(0)
export const doAnimation = writable(false)
export const planetRadius = writable(Re)
export const planetAxialTilt = writable(23.44 * DEG)
export const atmosphereThickness = writable(7 * 8e3)
export const elevation = writable(2)
export const elevationRad = derived(
  [elevation],
  ([$elevation]) => $elevation * DEG
)
export const observerOrigin = derived(
  [planetRadius],
  ([$planetRadius]) => new Vector3(0, $planetRadius, 0)
)
export const sunDistance = writable(1 * AU)
export const sunRadius = writable(109 * Re)
export const sunPosition = derived(
  [sunDistance, elevationRad],
  ([$sunDistance, $elevationRad]) => skyPosition($sunDistance, $elevationRad, 0)
)
export const sunDirection = derived(
  [sunPosition],
  ([$sunPosition]) => new Vector3().fromArray($sunPosition).normalize()
)

export const totalityFactor = writable(0.9)
export const moonRadius = writable(0.2727 * Re)
export const moonPerigee = writable(356500 * 1000 * METER)
export const moonApogee = writable(406700 * 1000 * METER)
export const moonOrbitInclination = writable(5.145 * DEG)
export const moonRightAscention = writable(0)
export const moonDistance = derived(
  [moonPerigee, moonApogee, totalityFactor],
  ([$moonPerigee, $moonApogee, $totalityFactor]) => MathUtils.lerp($moonPerigee, $moonApogee, 1 - $totalityFactor)
)
export const moonAxis = derived(
  [moonOrbitInclination, planetAxialTilt],
  ([$moonOrbitInclination, $planetAxialTilt]) => new Vector3(1, 0, 0).applyAxisAngle(new Vector3(0, 0, 1), $moonOrbitInclination + $planetAxialTilt)
)
export const moonAngleCorrection = derived(
  [moonDistance, sunDirection, observerOrigin, elevationRad],
  ([$moonDistance, $sunDirection, $observerOrigin, $elevationRad]) => {
    const int = sphereIntersection($observerOrigin, $sunDirection, $moonDistance)
    if (int === null) {
      return 0
    }
    const d = int[1]
    const m = $moonDistance
    const m2 = m * m
    const R = $observerOrigin.length()
    const R2 = $observerOrigin.lengthSq()
    const cosa = (R2 + m2 - d * d) / (2 * R * m)
    return 0.5 * Math.PI - Math.acos(cosa) - $elevationRad
  }
)
export const moonPosition = derived(
  [moonDistance, elevationRad, moonAxis, moonRightAscention, moonAngleCorrection],
  ([$moonDistance, $elevationRad, $moonAxis, $moonRightAscention, $moonAngleCorrection]) =>
    skyPosition($moonDistance, $elevationRad + $moonAngleCorrection, 0, new Vector3())
      .applyAxisAngle($moonAxis, $moonRightAscention)
)

const getMie = (n, k) => {
  return k * 1e26 * 8 * Math.pow(Math.PI, 3) * Math.pow((n * n - 1), 2) / 3 / 2.547e+25
}

const getRayleigh = (n, k) => {
  const rgb = [680, 510, 440]
  const corr = 1e10
  const a = getMie(n, k)
  const r = new Vector3(
    corr * a * Math.pow(1 / rgb[0], 4),
    corr * a * Math.pow(1 / rgb[1], 4),
    corr * a * Math.pow(1 / rgb[2], 4)
  )
  console.log(r, a)
  return r
}

const print = (val, ...args) => {
  console.log(val, ...args)
  return val
}

export const sunIntensity = writable(25)
export const overrideRayleigh = writable(false)
// 5.5e-6, 13.0e-6, 22.4e-6
export const rayleighRed = writable(5.5)
export const rayleighGreen = writable(13)
export const rayleighBlue = writable(22.4)
export const rayleighScaleHeight = writable(8e3)
export const mieCoefficient = writable(4.4e-6)
export const mieScaleHeight = writable(1.2e3)
export const mieDirectional = writable(-0.758)
export const airIndexRefraction = writable(1.0003)
export const airSurfacePressure = writable(101.3e3)
export const airSurfaceTemperature = writable(288)
export const airDensityFactor = derived(
  [airSurfacePressure, airSurfaceTemperature],
  ([$P, $T]) => print((288 / 101.3e3) * ($P / $T), $P, $T)
)
export const rayleighCoefficient = derived(
  [airIndexRefraction, airDensityFactor, overrideRayleigh, rayleighRed, rayleighGreen, rayleighBlue],
  ([$n, $air, $overrideRayleigh, $rayleighRed, $rayleighGreen, $rayleighBlue]) => {
    if ($overrideRayleigh) {
      return new Vector3($rayleighRed * 1e-6, $rayleighGreen * 1e-6, $rayleighBlue * 1e-6)
    }
    return getRayleigh($n, $air)
  }
)
// clouds
export const cloudZ = writable(0.2)
export const cloudThickness = writable(4)
export const cloudSize = writable(1)
export const cloudMie = writable(0.78)
export const cloudThreshold = writable(0.4)
export const cloudAbsorption = writable(0.2)
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

  altitude,
  fogHue,
  eclipseProgress,
  doAnimation,
  elevation,
  planetRadius,
  planetAxialTilt,
  atmosphereThickness,
  airIndexRefraction,
  airSurfacePressure,
  airSurfaceTemperature,

  sunDistance,
  sunRadius,

  totalityFactor,

  moonRadius,
  moonPerigee,
  moonApogee,

  moonOrbitInclination,
  moonRightAscention,
  moonPosition,

  sunIntensity,

  overrideRayleigh,
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
  cloudAbsorption,
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