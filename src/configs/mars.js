import { bothApsis } from '../lib/orbit'
import {
  METER,
  Re,
  AU,
  DEG,
  mBar,
  DAYS,
  HOURS
} from '../lib/units'

const moons = {
  phobos: {
    moonRadius: 11.1e3 * METER,
    moonOrbitInclination: 1.08 * DEG,
    moonOrbitPeriod: 0.31891 * DAYS,
    ...bothApsis(9378 * 1000 * METER, 0.0151, 'moon')
  },
  deimos: {
    moonRadius: 6.2e3 * METER,
    moonOrbitInclination: 1.788 * DEG,
    moonOrbitPeriod: 1.263 * DAYS,
    ...bothApsis(23459 * 1000 * METER, 0.0005, 'moon')
  },
}

export default {
  fogHue: 0,
  sunDistance: 1.52 * AU,
  sunIntensity: 15,
  dayLength: 24.6597 * HOURS,

  planetRadius: 0.53 * Re,
  planetAxialTilt: 25.19 * DEG,

  rayleighScaleHeight: 11.1e3,
  atmosphereThickness: 9 * 11.1e3,
  overrideRayleigh: false,
  // rayleighRed: 10.9,
  // rayleighGreen: 7.4,
  // rayleighBlue: 4.7,
  // rayleighRed: 11.2, //11.6,
  // rayleighGreen: 7.2, //6.4,
  // rayleighBlue: 4.6, //3.6,

  // mieRed: 0.3, // 3.1
  // mieGreen: 0.9, // 2.3
  // mieBlue: 1.8, // 1.6
  // mieDirectional: 0.758, // 0.6
  // mieScaleHeight: 1000,

  // mieRed: 37.8,
  // mieGreen: 26.1,
  // mieBlue: 18.1,
  mieRed: 17.8,
  mieGreen: 11.6,
  mieBlue: 7.3,

  mieWavelengthRed: 0.78,
  mieWavelengthGreen: .89,
  mieWavelengthBlue: .97,

  mieAmount: 6.7e-7,
  mieScaleHeight: 8770,
  mieDirectional: 0.81,
  mieBaseline: 0.29,

  ozoneRed: 10,
  ozoneGreen: 10,
  ozoneBlue: 10,
  ozoneLayerHeight: 4.6e3,
  ozoneLayerWidth: 20e3,

  windSpeed: 10,
  cloudZ: 0.01,
  cloudThickness: 2,
  cloudSize: 3.6,
  cloudMie: 0.31,
  cloudThreshold: 0.34,
  cloudAbsorption: 0.02,

  airIndexRefraction: 1.00045,
  airSurfacePressure: 6.36 * mBar,
  airSurfaceTemperature: 210,

  ...moons.phobos,
  moons,
}