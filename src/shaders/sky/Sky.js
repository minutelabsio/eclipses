import { ShaderMaterial } from 'three'
import * as THREE from 'three'
import vertexShader from './vertex.glsl'
import fragmentShader from './fragment.glsl'
import { debounce } from 'lodash'

const lineCircleIntersectionPoints = (r, s, radius) => {
  const b = s.dot(r);
  const c = r.dot(r) - (radius * radius);
  const d = b * b - c;
  if (d < 0.0) {
    return new THREE.Vector2(1e-5, -1e-5);
  }
  const sqrtd = Math.sqrt(d);
  const x0 = -b - sqrtd;
  const x1 = -b + sqrtd;
  if (x0 > x1) {
    return new THREE.Vector2(x1, x0);
  } else {
    return new THREE.Vector2(x0, x1);
  }
}

const opticalDensity = (r, planetRadius, H) => {
  if (H === 0) {
    return 0
  }
  const hr = r.length() - planetRadius;
  return Math.exp(-hr / H);
}

export default () => {
  const dimension = 4//4 * 512
  const opticalDepthMap = new Float32Array(dimension * dimension * 2)
  const opticalDepthMapTexture = new THREE.DataTexture(opticalDepthMap, dimension, dimension, THREE.RGFormat, THREE.FloatType)
  opticalDepthMapTexture.colorSpace = THREE.LinearSRGBColorSpace

  const shader = new ShaderMaterial({
    vertexShader,
    fragmentShader,
    blending: THREE.AdditiveBlending,
    side: THREE.BackSide,
    transparent: true,
    depthTest: false,
  })
  shader.toneMapped = false

  const METER = 1
  const Re = 6378 * 1000 * METER
  const AU = 149597870700 * METER
  const sunDistance = 1 * AU
  const sunRadius = 109 * Re

  const uniforms = {
    opacity: 1,
    moonPosition: new THREE.Vector3(0, 0, 0),
    moonRadius: 0.2727 * Re,
    altitude: 0,
    sunIntensity: 16,
    sunPosition: new THREE.Vector3(0, 0, -sunDistance),
    sunRadius,
    planetRadius: 6371e3,
    atmosphereThickness: 80e3, // karman line
    rayleighCoefficients: new THREE.Vector3(5.5e-6, 13.0e-6, 22.4e-6),
    rayleighScaleHeight: 8e3,
    mieCoefficient: 21e-6,
    mieScaleHeight: 500,
    mieDirectional: -0.758,
    exposure: 1.0,
    iSteps: 10,
    jSteps: 4,
  }

  const api = { shader }

  const getOpticalDepths = (theta, height) => {
    const steps = 64
    const units = api.atmosphereThickness
    const planetRadius = api.planetRadius / units
    const rH = api.rayleighScaleHeight / units
    const mH = api.mieScaleHeight / units
    const r = new THREE.Vector2(0, height / units + 1 / units + planetRadius)
    const s = new THREE.Vector2(Math.sin(theta), Math.cos(theta))
    const atmosphereInt = lineCircleIntersectionPoints(r, s, planetRadius + 1)
    let dist = atmosphereInt.y
    // const planetInt = lineCircleIntersectionPoints(r, s, planetRadius)
    // if (planetInt.x < planetInt.y && planetInt.x > 0) {
    //   dist = planetInt.x
    //   // return [1e9, 1e9]
    // }

    const ds = dist / steps;
    let odh = 0
    let odm = 0
    const pos = r.clone().addScaledVector(s, ds / 2);
    for (let i = 0; i < steps; i++) {
      odh += opticalDensity(pos, planetRadius, rH) * ds;
      odm += opticalDensity(pos, planetRadius, mH) * ds;
      pos.addScaledVector(s, ds);
    }
    return [odh * units, odm * units]
  }

  const logHeightScale = (i) => {
    if (i === 0) {
      return 0
    }
    if (i === (dimension - 1)) {
      return api.atmosphereThickness
    }
    return -Math.log(1 - i / (dimension - 1)) * api.rayleighScaleHeight
  }

  const thetaScale = (j) => {
    const t = j / (dimension - 1)
    return t * Math.PI
    // const c = Math.acos(1 - Math.sin(Math.PI * t)) / Math.PI
    // return (t > 0.5 ? 1 - c : c) * Math.PI
  }

  const refreshOpticalDepthMap = debounce(() => {
    for (let i = 0; i < dimension; i++) {
      const height = logHeightScale(i)
      for (let j = 0; j < dimension; j++) {
        const theta = thetaScale(j)
        const [odh, odm] = getOpticalDepths(theta, height)
        opticalDepthMap[i * 2 * dimension + j * 2] = odh
        opticalDepthMap[i * 2 * dimension + j * 2 + 1] = odm
      }
    }
    const max = opticalDepthMap.reduce((a, b) => Math.max(a, b), 0)
    opticalDepthMapTexture.needsUpdate = true
    console.log('updated optical depth map', opticalDepthMap, max)
  }, 100)

  const defineUniform = (key) => {
    shader.uniforms[key] = { value: uniforms[key] }
    Object.defineProperty(api, key, {
      get() {
        return shader.uniforms[key].value
      },
      set(value) {
        shader.uniforms[key].value = value
        shader.uniforms[key].needsUpdate = true
        if (key === 'planetRadius' || key === 'atmosphereThickness' || key === 'rayleighScaleHeight' || key === 'mieScaleHeight') {
          refreshOpticalDepthMap()
        }
        return value
      },
    })
  }

  Object.keys(uniforms).forEach(defineUniform)
  refreshOpticalDepthMap()
  shader.uniforms.opticalDepthMap = { value: opticalDepthMapTexture }
  shader.uniforms.opticalDepthMapSize = { value: dimension }

  return api
}