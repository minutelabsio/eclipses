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

  shader.uniforms.topColor = { value: new THREE.Color(0x0077ff) }
  shader.uniforms.bottomColor = { value: new THREE.Color(0x999999) }
  shader.uniforms.offset = { value: 33 }
  shader.uniforms.exponent = { value: 0.6 }
  shader.uniforms.opacity = { value: 1 }

  return {
    shader,
    get opacity(){
      return shader.uniforms.opacity.value
    },
    set opacity(opacity) {
      shader.uniforms.opacity.value = opacity
      shader.uniforms.opacity.needsUpdate = true
      return opacity
    },
    get bottomColor(){
      return shader.uniforms.bottomColor.value
    },
    set bottomColor(color) {
      shader.uniforms.bottomColor.value = color
      shader.uniforms.bottomColor.needsUpdate = true
      return color
    },
    get topColor(){
      return shader.uniforms.topColor.value
    },
    set topColor(color) {
      shader.uniforms.topColor.value = color
      shader.uniforms.topColor.needsUpdate = true
      return color
    },
    get offset(){
      return shader.uniforms.offset.value
    },
    set offset(offset) {
      shader.uniforms.offset.value = offset
      shader.uniforms.offset.needsUpdate = true
      return offset
    },
    get exponent(){
      return shader.uniforms.exponent.value
    },
    set exponent(exponent) {
      shader.uniforms.exponent.value = exponent
      shader.uniforms.exponent.needsUpdate = true
      return exponent
    },
  }
}