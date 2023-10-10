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

  shader.uniforms.uSunDir = { value: new THREE.Vector3(0, 0, -1) }
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
    get sunDir(){
      return shader.uniforms.uSunDir.value
    },
    set sunDir(pos) {
      shader.uniforms.uSunDir.value = pos
      shader.uniforms.uSunDir.needsUpdate = true
      return pos
    },
  }
}