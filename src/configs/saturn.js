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

const planetAxialTilt = 26.73 * DEG

const moons = {
  mimas: {
    moonRadius: 198.6 * 1000 * METER,
    moonOrbitInclination: 1.53 * DEG - planetAxialTilt,
    moonOrbitPeriod: 0.9424218 * DAYS,
    ...bothApsis(185.52e3 * 1000 * METER, 0.0202, 'moon')
  },
  enceladus: {
    // 257 x 251 x 248
    moonRadius: 252 * 1000 * METER,
    moonOrbitInclination: -planetAxialTilt,
    moonOrbitPeriod: 1.370218 * DAYS,
    ...bothApsis(238.02e3 * 1000 * METER, 0.0045, 'moon')
  },
  tethys: {
    // 538 x 528 x 526
    moonRadius: 531.1 * 1000 * METER,
    moonOrbitInclination: 1.86 * DEG - planetAxialTilt,
    moonOrbitPeriod: 1.887802 * DAYS,
    ...bothApsis(294.66e3 * 1000 * METER, 0.000, 'moon')
  },
  dione: {
    // 563 x 561 x 560
    moonRadius: 561.4 * 1000 * METER,
    moonOrbitInclination: 0.02 * DEG - planetAxialTilt,
    moonOrbitPeriod: 2.736915 * DAYS,
    ...bothApsis(377.4e3 * 1000 * METER, 0.0022, 'moon')
  },
  rhea: {
    // 765 x 763 x 762
    moonRadius: 764.3 * 1000 * METER,
    moonOrbitInclination: 0.35 * DEG - planetAxialTilt,
    moonOrbitPeriod: 4.517500 * DAYS,
    ...bothApsis(527.04e3 * 1000 * METER, 0.001, 'moon')
  },
  titan: {
    moonRadius: 2575 * 1000 * METER,
    moonOrbitInclination: 0.33 * DEG - planetAxialTilt,
    moonOrbitPeriod: 15.945421 * DAYS,
    ...bothApsis(1221.87e3 * 1000 * METER, 0.0292, 'moon')
  },
  hyperion: {
    // 180 x 133 x 103
    moonRadius: 138.6 * 1000 * METER,
    moonOrbitInclination: 0.43 * DEG - planetAxialTilt,
    moonOrbitPeriod: 21.276609 * DAYS,
    ...bothApsis(1500.93e3 * 1000 * METER, 0.1042, 'moon')
  },
  iapetus: {
    // 746 x 746 x 712
    moonRadius: 734.6 * 1000 * METER,
    moonOrbitInclination: 14.72 * DEG - planetAxialTilt,
    moonOrbitPeriod: 79.330183 * DAYS,
    ...bothApsis(3560.85e3 * 1000 * METER, 0.0283, 'moon')
  },
}

const planetRadius = 9.449 * Re
// jupiter
export default {
  fogHue: 0,
  sunDistance: 9.5 * AU, // between 10.12 and 9.04
  sunIntensity: 15,

  planetRadius,
  planetAxialTilt,
  dayLength: 10.656 * HOURS,

  overrideRayleigh: false,
  rayleighScaleHeight: 59.5e3 * METER,
  atmosphereThickness: 9 * 59.5e3 * METER,
  airIndexRefraction: 1.00015,
  airSurfacePressure: 1000 * mBar,
  airSurfaceTemperature: 134,

  windSpeed: 200,
  mieAmount: 0.0,
  mieDirectional: 0,
  mieScaleHeight: 0,
  // moon
  ...moons.titan,
  moons,

  cloudZ: -0.01, // below observer
}