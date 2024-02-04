import {
  METER,
  Re,
  AU,
  DEG,
  mBar
} from '../lib/units'

export default {
  fogHue: 0,
  planetRadius: 0.53 * Re,
  planetAxialTilt: 25.19 * DEG,
  rayleighScaleHeight: 11.1e3,
  atmosphereThickness: 9 * 11.1e3,
  windSpeed: 10,
  mieDirectional: -0.758,
  mieScaleHeight: 2000,
  airIndexRefraction: 1.00045,
  airSurfacePressure: 6.36 * mBar,
  airSurfaceTemperature: 210,

  sunDistance: 1.52 * AU,
  moonRadius: 11.08e3 * METER,
  moonPerigee: 9234.42 * 1000 * METER,
  moonApogee: 9517.58 * 1000 * METER,
  moonOrbitInclination: 26.04 * DEG,
}