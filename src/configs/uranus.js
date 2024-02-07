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
  airIndexRefraction: 1.00013881 * .825 + 1.000034388 * (1 - .825),
  airSurfacePressure: 1000 * mBar,
  airSurfaceTemperature: 76,

  windSpeed: 100,
  mieAmount: 0.0,
  mieDirectional: 0,
  mieScaleHeight: 0,
  // moon
  ...moons.miranda,
  moons,

  cloudZ: -200e3 / atmosphereThickness, // below observer
}