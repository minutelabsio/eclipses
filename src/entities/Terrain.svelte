<script>
  import { T } from '@threlte/core'
  import * as THREE from 'three'
  import { Easing } from 'intween'
  import Terrain from '../lib/three.terrain.js'
  import { Noise } from 'noisejs'

  export let color = 0x000000
  export let visible = true
  export let layers = 0
  export let renderOrder = 0

  const size = 4
  const xS = 63 * size
  const yS = 63 * size

  const random = (min, max) => Math.random() * (max - min) + min

  const island = function(coords) {
    const theta = Math.random() * Math.PI * 2
    coords.x = 0.5 + Math.cos(theta) * coords.x * 0.4
    coords.y = 0.5 + Math.sin(theta) * coords.y * 0.4
  }

  const valley = (coords) => {
    const theta = Math.random() * Math.PI * 2
    const r = 0.5 * Easing.quadOut(Math.sqrt(random(1e-3, 1)))
    coords.x = 0.5 + Math.cos(theta) * r
    coords.y = 0.5 + Math.sin(theta) * r
  }

  // const width = 1 << 11
  // const height = 1 << 11

  // const s = width * height
  // const data = new Uint8Array( 4 * s )

  // const noise = new Noise()

  // const dir = new THREE.Vector3(0, 1, 0)

  // for ( let i = 0; i < s; i++ ) {
  //   const stride = i * 4
  //   const xoff = (i % width) / 100
  //   const yoff = Math.floor(i / width) / 100
  //   const bw = Math.abs(noise.simplex2(xoff / 100, yoff / 100))
  //   dir.set(
  //     1,
  //     noise.simplex2(xoff, yoff + 1000),
  //     noise.simplex2(xoff, yoff),

  //   ).normalize()
  //   data[ stride ] = 255 * dir.x
  //   data[ stride + 1 ] = 255 * dir.y
  //   data[ stride + 2 ] = 255 * dir.z
  //   data[ stride + 3 ] = 0
  // }

  // // used the buffer to create a DataTexture
  // const texture = new THREE.DataTexture( data, width, height )
  // texture.needsUpdate = true
  // texture.wrapS = THREE.RepeatWrapping
  // texture.wrapT = THREE.RepeatWrapping
  // texture.repeat.set( 30, 30 )

  const material = new THREE.MeshStandardMaterial({
    color: 0x000000,
    dithering: true,
    // bumpMap: texture,
  })

  const terrainScene = Terrain({
    easing: Terrain.EaseInOut,
    frequency: 15,
    heightmap: (g, o, feature) => {
      Terrain.Hill(g, o, feature, valley)
    },
    material,
    maxHeight: 2000,
    minHeight: -0.1,
    steps: 1,
    xSegments: xS,
    xSize: 1024 * 32 * size,
    ySegments: yS,
    ySize: 1024 * 32 * size,
  })

  // terrainScene.children[0].castShadow = true
  // terrainScene.children[0].receiveShadow = true
  terrainScene.children[0].geometry.computeVertexNormals()
  $: material.color.set(color)
</script>

<T is={terrainScene} visible={visible} children.0.layers={layers} renderOrder={renderOrder} />