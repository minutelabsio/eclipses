<script>
  import { T } from '@threlte/core'
  import * as THREE from 'three'
  import { Easing } from 'intween'
  import Terrain from '../lib/three.terrain.js'

  export let color = 0x000000

  const size = 4
  const xS = 63 * size
  const yS = 63 * size

  const random = (min, max) => Math.random() * (max - min) + min

  const island = function(coords) {
    const theta = Math.random() * Math.PI * 2;
    coords.x = 0.5 + Math.cos(theta) * coords.x * 0.4;
    coords.y = 0.5 + Math.sin(theta) * coords.y * 0.4;
  };

  const valley = (coords) => {
    const theta = Math.random() * Math.PI * 2;
    const r = 0.5 * Easing.quadOut(Math.sqrt(random(0.001, 1)));
    coords.x = 0.5 + Math.cos(theta) * r;
    coords.y = 0.5 + Math.sin(theta) * r;
  }

  const material = new THREE.MeshStandardMaterial({ color: 0x000000, dithering: true })

  const terrainScene = Terrain({
    easing: Terrain.EaseInOut,
    frequency: 15,
    heightmap: (g, o, feature) => {
      Terrain.Hill(g, o, feature, valley);
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

  $: material.color.set(color)
</script>

<T is={terrainScene} />