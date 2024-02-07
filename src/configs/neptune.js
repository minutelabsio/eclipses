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

const planetAxialTilt = 28.32 * DEG

const moons = {
  naiad: {
    // 48 x 30 x 26
    moonRadius: 29.5 * 1000 * METER,
    moonOrbitInclination: 4.74 * DEG - planetAxialTilt,
    moonOrbitPeriod: 0.294396 * DAYS,
    ...bothApsis(48.227e3 * 1000 * METER, 0.0003, 'moon')
  },
  thalassa: {
    // 54 x 50 x 26
    moonRadius: (54 + 50 + 26) / 3 * 1000 * METER,
    moonOrbitInclination: 4.34 * DEG - planetAxialTilt,
    moonOrbitPeriod: 0.311485 * DAYS,
    ...bothApsis(50.075e3 * 1000 * METER, 0.0002, 'moon')
  },
  despina: {
    // 90 x 74 x 64
    moonRadius: (90 + 74 + 64) / 3 * 1000 * METER,
    moonOrbitInclination: 0.334655 * DEG - planetAxialTilt,
    moonOrbitPeriod: 1.413 * DAYS,
    ...bothApsis(52.526e3 * 1000 * METER, 0.0001, 'moon')
  },
  galatea: {
    // 102 x 92 x 72
    moonRadius: (102 + 92 + 72) / 3 * 1000 * METER,
    moonOrbitInclination: 0.428745 * DEG - planetAxialTilt,
    moonOrbitPeriod: 1.413 * DAYS,
    ...bothApsis(61.953e3 * 1000 * METER, 0.0001, 'moon')
  },
  larissa: {
    // 108 x 102 x 84
    moonRadius: (108 + 102 + 84) / 3 * 1000 * METER,
    moonOrbitInclination: 4.34 * DEG - planetAxialTilt,
    moonOrbitPeriod: 0.554654 * DAYS,
    ...bothApsis(73.548e3 * 1000 * METER, 0.0014, 'moon')
  },
  proteus: {
    // 220 x 208 x 202
    moonRadius: (220 + 208 + 202) / 3 * 1000 * METER,
    moonOrbitInclination: 4.34 * DEG - planetAxialTilt,
    moonOrbitPeriod: 1.122315 * DAYS,
    ...bothApsis(117.647e3 * 1000 * METER, 0.00, 'moon')
  },
  triton: {
    moonRadius: 1353.4 * 1000 * METER,
    moonOrbitInclination: 4.34 * DEG - planetAxialTilt,
    moonOrbitPeriod: -5.876854 * DAYS,
    ...bothApsis(354.76e3 * 1000 * METER, 0.000016, 'moon')
  },
  nereid: {
    moonRadius: 170 * 1000 * METER,
    moonOrbitInclination: 4.34 * DEG - planetAxialTilt,
    moonOrbitPeriod: 360.13619 * DAYS,
    ...bothApsis(5513.4e3 * 1000 * METER, 0.7512, 'moon')
  }
}

const planetRadius = 4.007 * Re
const atmosphereThickness = 9 * 20e3 * METER
// jupiter
export default {
  fogHue: 200,
  sunDistance: 30 * AU, // 29.81 to 30.33
  sunIntensity: 1,

  planetRadius,
  planetAxialTilt,
  dayLength: 16.11 * HOURS,

  overrideRayleigh: false,
  rayleighScaleHeight: 20e3 * METER,
  atmosphereThickness,
  // i don't know if this is the right way to do this...
  airIndexRefraction: 1.00013881 * .8 + 1.000034388 * .2,
  airSurfacePressure: 1000 * mBar,
  airSurfaceTemperature: 72,

  windSpeed: 100,
  mieAmount: 0.0,
  mieDirectional: 0,
  mieScaleHeight: 0,
  // moon
  ...moons.niaid,
  moons,

  cloudZ: 0.01,
}