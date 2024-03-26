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
  airIndexRefraction: 1.00013881 * 0.8 + 1.000034388 * 0.185 + 1.00043650 * 0.015,
  airSurfacePressure: 1000 * mBar,
  airSurfaceTemperature: 72,

  // apparently the latest news is neptune is roughly the color of uranus
  // so... i guess use the same parameters but put less methane in the atmosphere...
  mieAmount: 1.2e-6,
  mieDirectional: 0,
  mieScaleHeight: 7000,

  mieRed: 0.79,
  mieGreen: 4.03,
  mieBlue: 6.47,

  mieWavelengthRed: 0.1,
  mieWavelengthGreen: 0.1,
  mieWavelengthBlue: 0.1,
  mieBaseline: 0,

  ozoneRed: 7.8,
  ozoneGreen: 2.4,
  ozoneBlue: 2.1,
  ozoneLayerHeight: 0,
  ozoneLayerWidth: 30000,

  windSpeed: 100,
  cloudZ: 0.2,
  cloudThickness: 10,
  cloudSize: 0.2,
  cloudMie: 0,
  cloudThreshold: 0.35,
  cloudAbsorption: 0.03,

  // moon
  ...moons.despina,
  moons,
  defaultMoon: 'despina'
}