import { ShaderMaterial, TextureLoader } from 'three'
import * as THREE from 'three'
import vertexShader from './vertex.glsl'
import fragmentShader from './fragment.glsl'
import corona from '../../assets/corona.jpg'
import { sunIntensity } from '../../store/environment'
import { get } from 'svelte/store'

const coronaTexture = new TextureLoader().load(corona)

export default ({
  opacity = 1
} = {}) => {
  const shader = new ShaderMaterial({
    vertexShader,
    fragmentShader,
    blending: THREE.AdditiveBlending,
    transparent: true,
    depthWrite: false,
  })

  shader.uniforms.uOpacity = { value: opacity }
  shader.uniforms.uCoronaTexture = { value: coronaTexture }
  shader.uniforms.uSunIntensity = { value: get(sunIntensity) }
  sunIntensity.subscribe(value => {
    shader.uniforms.uSunIntensity.value = value
    shader.uniforms.uSunIntensity.needsUpdate = true
  })
  return shader
}