<script>
  import { useFrame } from '@threlte/core'
  import Stats from 'stats.js'
  import { onMount } from 'svelte'

  let stats
  useFrame(() => {
    stats?.end()
    stats?.begin()
  })
  onMount(() => {
    stats = new Stats()
    stats.showPanel(0)
    document.body.appendChild(stats.dom)

    return () => {
      document.body.removeChild(stats.dom)
    }
  })
</script>
