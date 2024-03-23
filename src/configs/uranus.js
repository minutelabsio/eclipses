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

const planetAxialTilt = 82.23 * DEG

const moons = {
  miranda: {
    // 240 x 234.2 x 232.9
    moonRadius: 235.8 * 1000 * METER,
    moonOrbitInclination: 4.34 * DEG - planetAxialTilt,
    moonOrbitPeriod: 1.413 * DAYS,
    ...bothApsis(129.90e3 * 1000 * METER, 0.0013, 'moon')
  },
  ariel: {
    // 581.1 x 577.9 x 577.7
    moonRadius: 578.9 * 1000 * METER,
    moonOrbitInclination: 0.04 * DEG - planetAxialTilt,
    moonOrbitPeriod: 2.52 * DAYS,
    ...bothApsis(190.90e3 * 1000 * METER, 0.0012, 'moon')
  },
  umbriel: {
    moonRadius: 584.7 * 1000 * METER,
    moonOrbitInclination: 0.13 * DEG - planetAxialTilt,
    moonOrbitPeriod: 4.144177 * DAYS,
    ...bothApsis(266.00e3 * 1000 * METER, 0.0039, 'moon')
  },
  titania: {
    moonRadius: 788.9 * 1000 * METER,
    moonOrbitInclination: 0.08 * DEG - planetAxialTilt,
    moonOrbitPeriod: 8.705872 * DAYS,
    ...bothApsis(436.30e3 * 1000 * METER, 0.0011, 'moon')
  },
  oberon: {
    moonRadius: 761.4 * 1000 * METER,
    moonOrbitInclination: 0.07 * DEG - planetAxialTilt,
    moonOrbitPeriod: 13.463239 * DAYS,
    ...bothApsis(583.50e3 * 1000 * METER, 0.0014, 'moon')
  },
}

const planetRadius = 4.007 * Re
const atmosphereThickness = 9 * 27.7e3 * METER
// jupiter
export default {
  fogHue: 0,
  sunDistance: 19.22 * AU, // between 20.09 and 18.28
  sunIntensity: 2,

  planetRadius,
  planetAxialTilt,
  dayLength: 17.24 * HOURS,

  overrideRayleigh: false,
  rayleighScaleHeight: 27.7e3 * METER,
  atmosphereThickness,
  // i don't know if this is the right way to do this...
  airIndexRefraction: 1.00013881 * 0.825 + 1.000034388 * 0.152 + 1.00043650 * 0.023,
  airSurfacePressure: 1000 * mBar,
  airSurfaceTemperature: 76,

  mieAmount: 1.7e-5,
  mieDirectional: 0.36,
  mieScaleHeight: 13800,

  mieRed: 0.2,
  mieGreen: 0.8,
  mieBlue: 2.4,

  mieWavelengthRed: 0.3,
  mieWavelengthGreen: 0.15,
  mieWavelengthBlue: 0.13,
  mieBaseline: 0,

  ozoneRed: 0,
  ozoneGreen: 0,
  ozoneBlue: 0,

  // moon
  ...moons.miranda,
  moons,

  windSpeed: 100,
  cloudZ: 0.2,
  cloudThickness: 4.2,
  cloudSize: 0.1,
  cloudMie: 0.35,
  cloudThreshold: 0.49,
  cloudAbsorption: 0.49,
}