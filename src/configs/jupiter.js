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
  io: {
    moonRadius: 1821.5 * 1000 * METER,
    moonOrbitInclination: -2.213 * DEG,
    moonOrbitPeriod: 1.769138 * DAYS,
    ...bothApsis(421.8e3 * 1000 * METER, 0.004, 'moon')
  },
  europa: {
    moonRadius: 1560.8 * 1000 * METER,
    moonOrbitInclination: -1.791 * DEG,
    moonOrbitPeriod: 3.551181 * DAYS,
    ...bothApsis(671.1e3 * 1000 * METER, 0.009, 'moon')
  },
  ganymede: {
    moonRadius: 2631.2 * 1000 * METER,
    moonOrbitInclination: -2.214 * DEG,
    moonOrbitPeriod: 7.154553 * DAYS,
    ...bothApsis(1070.4e3 * 1000 * METER, 0.001, 'moon')
  },
  callisto: {
    moonRadius: 2410.3 * 1000 * METER,
    moonOrbitInclination: -2.017 * DEG,
    moonOrbitPeriod: 16.689017 * DAYS,
    ...bothApsis(1882.7e3 * 1000 * METER, 0.007, 'moon')
  },
  amalthea: {
    moonRadius: 83.5 * 1000 * METER,
    moonOrbitInclination: -2.756 * DEG,
    moonOrbitPeriod: 0.498179 * DAYS,
    ...bothApsis(181.4e3 * 1000 * METER, 0.003, 'moon')
  }
}

const planetRadius = 10.973 * Re
const atmosphereThickness = 9 * 27e3 * METER
// jupiter
export default {
  fogHue: 0,
  sunDistance: 5.2038 * AU,
  sunIntensity: 10,

  planetRadius,
  planetAxialTilt: 3.13 * DEG,
  dayLength: 9.926 * HOURS,

  overrideRayleigh: false,
  rayleighScaleHeight: 27e3 * METER,
  atmosphereThickness,
  airIndexRefraction: 1.00015,
  airSurfacePressure: 1000 * mBar,
  airSurfaceTemperature: 165,

  mieRed: 0.8,
  mieGreen: 5.9,
  mieBlue: 32.5,

  mieWavelengthRed: 0.8,
  mieWavelengthGreen: 0.85,
  mieWavelengthBlue: 0.9,

  mieAmount: 2e-5,
  mieDirectional: 1e-5,
  mieScaleHeight: 11000,

  ozoneLayerHeight: 27e3 * METER,
  ozoneLayerWidth: 27e3 * METER,
  ozoneRed: 4.3,
  ozoneGreen: 14.6,
  ozoneBlue: 40,

  // moon
  ...moons.amalthea,
  moons,

  windSpeed: 100,
  cloudZ: 100e3 * METER / atmosphereThickness,
  cloudThickness: 0.4,
  cloudSize: 0.1,
  cloudMie: 0.2,
  cloudThreshold: 0.2,
  cloudAbsorption: 0.05,
}