import {
  METER,
  Re,
  AU,
  DEG
} from '../lib/units'
// jupiter
export default {
  fogHue: 0,
  planetRadius: 10.973 * Re,
  planetAxialTilt: 3.13 * DEG,
  rayleighScaleHeight: 27e3 * METER,
  atmosphereThickness: 7 * 27e3 * METER,
  windSpeed: 100,
  mieCoefficient: 0,
  mieDirectional: -0.758,
  mieScaleHeight: 2000,
  sunDistance: 5.2038 * AU,
  // Callisto
  moonRadius: 0.378 * Re,
  moonPerigee: 1869000 * 1000 * METER,
  moonApogee: 1897000 * 1000 * METER,
  moonOrbitInclination: 2.017 * DEG,

  cloudZ: 25000 * METER / (7 * 27e3 * METER)
}