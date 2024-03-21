import {
  METER,
  Re,
  AU,
  DEG,
  DAYS,
  HOURS
} from '../lib/units'

const moons = {
  luna: {
    moonRadius: 0.2727 * Re,
    moonPeriapsis: 0.3633e9 * METER,
    moonApoapsis: 0.4055e9 * METER,
    moonOrbitInclination: 5.145 * DEG,
    moonOrbitPeriod: 27.3217 * DAYS,
  }
}

const atmosphereThickness = 9 * 8.5e3

export default {
  fogHue: 200,
  sunIntensity: 25,
  sunDistance: 1 * AU,

  planetRadius: Re,
  planetAxialTilt: 23.44 * DEG,
  dayLength: 24 * HOURS,

  atmosphereThickness,
  cloudZ: 1000 * METER / atmosphereThickness,
  cloudSize: 5,
  cloudThickness: .2,
  cloudMie: 0.8,
  cloudThreshold: 0.35,
  cloudAbsorption: 0.4,
  windSpeed: 18,
  overrideRayleigh: false,
  rayleighScaleHeight: 8.5e3,
  mieRed: 15,
  mieGreen: 15,
  mieBlue: 15,

  mieDirectional: 0.72,
  mieScaleHeight: 1000,
  mieAmount: 4e-6,
  mieWavelengthRed: 0.8,
  mieWavelengthGreen: 0.8,
  mieWavelengthBlue: 0.8,
  ozoneRed: 3.5,
  ozoneGreen: 1.7,
  ozoneBlue: 0.085,
  // ozoneRed: 1.4,
  // ozoneGreen: 1.2,
  // ozoneBlue: 0.085,
  ozoneLayerHeight: 25e3,
  ozoneLayerWidth: 35e3,

  airIndexRefraction: 1.0003,
  airSurfacePressure: 101325,
  airSurfaceTemperature: 288,

  ...moons.luna,
  moons,
}