<script>
import { onMount } from "svelte"
// This component gets mounted to the body
let container
onMount(() => {
  document.body.appendChild(container)
  return () => {
    document.body.removeChild(container)
  }
})
</script>

<aside bind:this={container}>
  <slot></slot>
</aside>