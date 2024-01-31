import {
  METER,
  Re,
  AU,
  DEG
} from '../lib/units'

export default {
  fogHue: 200,
  planetRadius: Re,
  planetAxialTilt: 23.44 * DEG,
  atmosphereThickness: 7 * 8.5e3,
  windSpeed: 8,
  rayleighScaleHeight: 8.5e3,
  mieCoefficient: 21e-6,
  mieDirectional: -0.758,
  mieScaleHeight: 500,
  sunDistance: 1 * AU,
  moonRadius: 0.2727 * Re,
  moonPerigee: 356500 * 1000 * METER,
  moonApogee: 406700 * 1000 * METER,
  moonOrbitInclination: 5.145 * DEG,
}