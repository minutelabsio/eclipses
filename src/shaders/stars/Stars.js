import * as THREE from 'three'
// TODO: change assert => with when linting supports it
import { starData } from './starData' assert { type: 'macro' };

function vertexShader() {
  return `
    attribute float size;
    attribute vec4 color;
    varying vec4 vColor;
    void main() {
      vColor = color;
      vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );
      gl_PointSize = 6e9 * size * ( 250.0 / -mvPosition.z );
      gl_Position = projectionMatrix * mvPosition;
    }
  `
}

function fragmentShader() {
  return `
    varying vec4 vColor;
    uniform float exposure;
    void main() {
      gl_FragColor = vColor; //1.0 - exp(-exposure * vec4( vColor ));
    }
  `
}

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
    vertexShader: vertexShader(),
    fragmentShader: fragmentShader(),
    transparent: true,
  })

  starsMaterial.uniforms.exposure = { value: 1.0 }

  return new THREE.Points(starsGeometry, starsMaterial)
}