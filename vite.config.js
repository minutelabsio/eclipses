import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import pkg from './package.json'
import {glslify} from 'vite-plugin-glslify'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    glslify({
      exclude: 'src/lib/three.terrain.js'
    }),
    svelte()
  ],
  resolve: {
    dedupe: ['three'],
  },
  assetsInclude: ['**/*.tif', '**/*.dds'],
  base: process.env.NODE_ENV === 'production'
    ? `/${pkg.name}`
    : ''
})
