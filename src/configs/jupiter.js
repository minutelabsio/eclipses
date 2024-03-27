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

  // this is a best guess for ammonia clouds
  // and haze that dulls the rayleigh scattering
  mieRed: 5.12,
  mieGreen: 6.47,
  mieBlue: 7.8,

  mieWavelengthRed: 0.38,
  mieWavelengthGreen: 0.43,
  mieWavelengthBlue: 0.46,

  mieAmount: 5e-6,
  mieDirectional: .41,
  mieScaleHeight: 16200,
  mieBaseline: 0,

  ozoneLayerHeight: 2600,
  ozoneLayerWidth: 44e3 * METER,
  ozoneRed: 4.3,
  ozoneGreen: 14.6,
  ozoneBlue: 40,

  // moon
  ...moons.callisto,
  moons,
  defaultMoon: 'callisto',

  cloudZ: 100e3 * METER / atmosphereThickness,
  cloudThickness: 5,
  cloudSize: 0.1,
  cloudMie: 0.4,
  cloudThreshold: 0.36,
  cloudAbsorption: 0.45,
  windSpeed: 100,
}