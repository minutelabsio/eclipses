import {
  METER,
  Re,
  AU,
  DEG,
  mBar
} from '../lib/units'

const planetRadius = 10.973 * Re
// jupiter
export default {
  fogHue: 0,
  planetRadius,
  planetAxialTilt: 3.13 * DEG,
  overrideRayleigh: false,
  rayleighScaleHeight: 27e3 * METER,
  atmosphereThickness: 9 * 27e3 * METER,
  airIndexRefraction: 1.00015,
  airSurfacePressure: 1000 * mBar,
  airSurfaceTemperature: 165,

  windSpeed: 100,
  mieAmount: 0.0,
  mieDirectional: 0,
  mieScaleHeight: 0,
  sunDistance: 5.2038 * AU,
  // Callisto
  moonRadius: 0.378 * Re,
  moonPerigee: 1869000 * 1000 * METER,
  moonApogee: 1897000 * 1000 * METER,
  moonOrbitInclination: 2.017 * DEG,

  cloudZ: 25000 * METER / (7 * 27e3 * METER)
}