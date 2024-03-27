<script>
  import { T, useLoader } from '@threlte/core'
  import * as THREE from 'three'
  import { Easing } from 'intween'
  import Terrain from '../lib/three.terrain.js'
  import { Noise } from 'noisejs'
  import { useSuspense } from '@threlte/extras'
  import { TextureLoader } from 'three'
  // import aoTexture from '../assets/planet textures/snow pbr texture/Snow05 ao 4k.jpg'
  // import normalTexture from '../assets/planet textures/snow pbr texture/Snow05 normal 4k.jpg'

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
    color: 0x663322,
    dithering: true,
    roughness: 1,
    fog: true,
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

  const suspend = useSuspense()

  // const textures = suspend(useLoader(TextureLoader).load({
  //   normalTexture,
  //   aoTexture,
  // }))

  // textures.then((t) => {
  //   const rep = 3e4
  //   t.normalTexture.repeat.set(rep, rep)
  //   t.normalTexture.wrapS = t.normalTexture.wrapT = THREE.RepeatWrapping
  //   t.normalTexture.anisotropy = 16
  //   t.aoTexture.repeat.set(rep, rep)
  //   t.aoTexture.wrapS = t.aoTexture.wrapT = THREE.RepeatWrapping
  //   t.aoTexture.anisotropy = 16

  //   // const material = Terrain.generateBlendedMaterial([
  //   //   { texture: t.groundTexture },
  //   // ])
  //   // terrainScene.children[0].material = material
  //   material.normalMap = t.normalTexture
  //   material.aoMap = t.aoTexture
  //   material.needsUpdate = true
  // })
</script>

<T is={terrainScene} visible={visible} children.0.layers={layers} renderOrder={renderOrder} />