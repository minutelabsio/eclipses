import { ShaderMaterial } from 'three'
import * as THREE from 'three'
import vertexShader from './vertex.glsl'
import fragmentShader from './fragment.glsl'

export default () => {
  const shader = new ShaderMaterial({
    vertexShader,
    fragmentShader,
    blending: THREE.NoBlending,
    side: THREE.BackSide,
    transparent: true,
    // depthWrite: true,
  })

  shader.uniforms.uSunPos = { value: new THREE.Vector3(0, -0, -1) }

  return {
    shader,
  }
}