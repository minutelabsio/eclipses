import * as THREE from 'three'
// TODO: change assert => with when linting supports it
import { starData } from './starData' assert { type: 'macro' };
import { vertexShader, fragmentShader } from './shaders.js'
import { rayleighScaleHeight, altitude } from '../../store/environment'
import { derived } from 'svelte/store';

export default async function createStars(){
  const {
    positions,
    colors,
    sizes
  } = starData()

  const starsGeometry = new THREE.BufferGeometry()
  starsGeometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3))
  starsGeometry.setAttribute('color', new THREE.Float32BufferAttribute(colors, 4))
  starsGeometry.setAttribute('size', new THREE.Float32BufferAttribute(sizes, 1))

  const starsMaterial = new THREE.ShaderMaterial({
    vertexShader: vertexShader,
    fragmentShader: fragmentShader,
  })

  starsMaterial.uniforms.exposure = { value: 1.0 }
  starsMaterial.uniforms.time = { value: 0 }
  starsMaterial.uniforms.depth = { value: 0 }
  const z = derived([altitude, rayleighScaleHeight], ([$altitude, $rayleighScaleHeight]) => {
    return $altitude / $rayleighScaleHeight
  })
  z.subscribe(value => {
    starsMaterial.uniforms.depth.value = Math.exp(-value)
    starsMaterial.uniforms.depth.needsUpdate = true
  })

  function tick(time){
    requestAnimationFrame(tick)
    starsMaterial.uniforms.time.value = time
    starsMaterial.uniforms.time.needsUpdate = true
  }
  tick(0)

  return new THREE.Points(starsGeometry, starsMaterial)
}