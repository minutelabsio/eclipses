import { ShaderMaterial, TextureLoader } from 'three'
import * as THREE from 'three'
import vertexShader from './vertex.glsl'
import fragmentShader from './fragment.glsl'
import corona from '../../assets/corona.jpg'

const coronaTexture = new TextureLoader().load(corona)

export default () => {
  const shader = new ShaderMaterial({
    vertexShader,
    fragmentShader,
    // blending: THREE.AdditiveBlending,
    blending: THREE.CustomBlending,
    // blendEquation: THREE.AddEquation,
    blendSrc: THREE.OneFactor,
    blendDst: THREE.OneMinusSrcAlphaFactor,
    // this only works inside the atmosphere
    blendEquation: THREE.AddEquation,
    transparent: true,
    // dithering: true,
    side: THREE.DoubleSide,
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
    planetColor: new THREE.Color(0x111111),
    moonPosition: new THREE.Vector3(0, 0, 0),
    moonRadius: 0.2727 * Re,
    uAltitude: 0,
    sunIntensity: 25,
    sunPosition: new THREE.Vector3(0, 0, -sunDistance),
    sunRadius,
    planetRadius: 6371e3,
    atmosphereThickness: 7 * 8e3, // karman line is 80e3
    rayleighCoefficients: new THREE.Vector3(5.5e-6, 13.0e-6, 22.4e-6),
    rayleighScaleHeight: 8e3,
    mieCoefficients: new THREE.Vector3(21e-6, 21e-6, 21e-6),
    mieWavelengthResponse: new THREE.Vector3(0.2),
    mieScaleHeight: 500,
    mieDirectional: -0.758,
    ozoneLayerHeight: 25e3,
    ozoneLayerWidth: 30e3,
    ozoneCoefficients: new THREE.Vector3(1.4e-6, 1.2e-6, 0.085e-6),
    exposure: 1.0,
    iSteps: 6,
    jSteps: 5,
    // clouds
    cloudZ: 0.2,
    cloudThickness: 4.,
    cloudSize: 1.,
    cloudMie: 0.78,
    cloudThreshold: 0.4,
    cloudAbsorption: 0.2,
    windSpeed: 8,
    fisheye: false,
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

  shader.uniforms.time = { value: 0 }
  shader.uniforms.coronaTexture = { value: coronaTexture }
  api.update = (dt) => {
    shader.uniforms.time.value += dt / 1000
    shader.uniforms.time.needsUpdate = true
  }

  return api
}