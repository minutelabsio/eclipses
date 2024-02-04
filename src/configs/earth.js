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
  atmosphereThickness: 9 * 8.5e3,
  windSpeed: 8,
  rayleighScaleHeight: 8.5e3,
  mieDirectional: -0.758,
  mieScaleHeight: 500,
  airIndexRefraction: 1.0003,
  airSurfacePressure: 101325,
  airSurfaceTemperature: 288,

  sunDistance: 1 * AU,
  moonRadius: 0.2727 * Re,
  moonPerigee: 356500 * 1000 * METER,
  moonApogee: 406700 * 1000 * METER,
  moonOrbitInclination: 5.145 * DEG,
}