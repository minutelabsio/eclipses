import { ShaderMaterial } from 'three'
import * as THREE from 'three'
import vertexShader from './vertex.glsl'
import fragmentShader from './fragment.glsl'

export default () => {
  const shader = new ShaderMaterial({
    vertexShader,
    fragmentShader,
    blending: THREE.AdditiveBlending,
    side: THREE.BackSide,
    transparent: true,
    depthWrite: false,
  })

  const uniforms = {
    opacity: 1,
    altitude: 0,
    sunIntensity: 22.0,
    sunDir: new THREE.Vector3(0, 0, -1),
    planetRadius: 6371e3,
    atmosphereThickness: 10e3,
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