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
  windSpeed: 10,
  cloudThickness: 0.01,
  cloudAbsorption: 0.04,

  rayleighScaleHeight: 11.1e3,
  atmosphereThickness: 9 * 11.1e3,
  overrideRayleigh: true,
  rayleighRed: 10.9,
  rayleighGreen: 7.4,
  rayleighBlue: 4.7,
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
  mieRed: 4.4,
  mieGreen: 33.8,
  mieBlue: 40,

  mieWavelengthRed: 0.75,
  mieWavelengthGreen: 0.85,
  mieWavelengthBlue: 0.89,

  mieAmount: 5e-7,
  mieDirectional: 0.01,
  mieScaleHeight: 1200,

  cloudZ: 0.01,
  cloudThickness: 0.9,
  cloudSize: 3.6,
  cloudMie: 0.31,
  cloudThreshold: 0.34,
  cloudAbsorption: 0.04,

  airIndexRefraction: 1.00045,
  airSurfacePressure: 6.36 * mBar,
  airSurfaceTemperature: 210,

  ...moons.phobos,
  moons,
}