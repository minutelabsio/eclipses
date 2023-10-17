import { ShaderMaterial } from 'three'
import * as THREE from 'three'
import vertexShader from './vertex.glsl'
import fragmentShader from './fragment.glsl'

export default () => {
  const shader = new ShaderMaterial({
    vertexShader,
    fragmentShader,
    // blending: THREE.AdditiveBlending,
    side: THREE.BackSide,
    transparent: true,
    depthWrite: false,
  })

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
    sunIntensity: 22.0,
    sunPosition: new THREE.Vector3(0, 0, -sunDistance),
    sunRadius,
    planetRadius: 6371e3,
    atmosphereThickness: 100e3, // karman line
    rayleighCoefficients: new THREE.Vector3(5.5e-6, 13.0e-6, 22.4e-6),
    rayleighScaleHeight: 8e3,
    mieCoefficient: 21e-6,
    mieScaleHeight: 1.2e3,
    mieDirectional: 0.758,
  }

  const api = { shader }

  const defineUniform = (key) => {
    shader.uniforms[key] = { value: uniforms[key] }
    Object.defineProperty(api, key, {
      get() {
        return shader.uniforms[key].value
      },
      set(value) {
        shader.uniforms[key].value = value
        shader.uniforms[key].needsUpdate = true
        return value
      },
    })
  }

  Object.keys(uniforms).forEach(defineUniform)

  return api
}