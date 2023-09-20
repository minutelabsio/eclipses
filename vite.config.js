import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import pkg from './package.json'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [svelte()],
  base: process.env.NODE_ENV === 'production'
    ? `/${pkg.name}/`
    : '/'
})
