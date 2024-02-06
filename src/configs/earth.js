import {
  METER,
  Re,
  AU,
  DEG
} from '../lib/units'

const atmosphereThickness = 9 * 8.5e3

export default {
  fogHue: 200,
  planetRadius: Re,
  planetAxialTilt: 23.44 * DEG,
  atmosphereThickness,
  cloudZ: 1000 * METER / atmosphereThickness,
  cloudSize: 5,
  cloudThickness: 5.2,
  cloudMie: 0.62,
  cloudThreshold: 0.35,
  cloudAbsorption: 0.17,
  windSpeed: 8,
  overrideRayleigh: false,
  rayleighScaleHeight: 8.5e3,
  mieRed: 15,
  mieGreen: 15,
  mieBlue: 15,

  mieAmount: 0.000003,
  mieWavelengthRed: 0.9,
  mieWavelengthGreen: 0.9,
  mieWavelengthBlue: 0.9,

  mieDirectional: 0.03,
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