<script>
  import * as PlanetConfigs from '../configs'
  import interact from 'interactjs'
  import { onMount, createEventDispatcher } from 'svelte'
  import * as moonMasks from '../lib/moon-masks.js'

  export let planet = 'earth'
  export let hoveringMoon = 'luna'

  const dispatch = createEventDispatcher()

  const circleSize = 400
  const minMoonSize = 0.2
  const selectedItemWidth = 90
  const itemWidth = 90
  const segmentPct = 3.5

  const getMoonsFor = (planet) => {
    const moons = Object.entries(PlanetConfigs[planet].moons)
      .map(([name, cfg]) => ({ name, radius: cfg.moonRadius, distance: cfg.moonDistance }))
      .sort((a, b) => a.distance - b.distance)

    // largest moon
    const largest = moons.reduce((a, b) => a?.radius > b.radius ? a : b)
    return moons.map(moon => {
      const mask = moonMasks[moon.name]
      return {
        name: moon.name,
        size: Math.max(minMoonSize, moon.radius / largest.radius),
        active: false,
        mask
      }
    })
  }

  const getMenuItems = (moons, hoveringMoon) => {
    if (!moons.find(moon => moon.name === hoveringMoon)) {
      hoveringMoon = PlanetConfigs[planet].defaultMoon ?? moons[0].name
      return moons
    }
    return moons.map(moon => {
      if (moon.name === hoveringMoon) {
        return { ...moon, active: true }
      }
      return moon
    })
  }

  const carousel = (index, segment) => {
    return index * segment
  }

  const selectMoon = (item) => () => {
    if (item.name === hoveringMoon) {
      dispatch('select', { name: item.name })
    } else {
      hoveringMoon = item.name
    }
  }

  let dx = 0

  $: moons = getMoonsFor(planet)
  $: hoveringMoon = moons.find(m => m.name === hoveringMoon) ? hoveringMoon : PlanetConfigs[planet].defaultMoon ?? moons[0].name
  $: menuItems = getMenuItems(moons, hoveringMoon)
  $: selectedIndex = menuItems.findIndex(item => item.active)
  $: da = dx / (circleSize * Math.PI * 2) * 360
  $: rot = carousel(selectedIndex, segmentPct * 3.6) + da

  const next = () => {
    hoveringMoon = menuItems[selectedIndex + 1]?.name || menuItems[0].name
  }

  const prev = () => {
    hoveringMoon = menuItems[selectedIndex - 1]?.name || menuItems[menuItems.length - 1].name
  }

  const onkey = (e) => {
    if (e.key === 'ArrowRight') {
      next()
    }
    if (e.key === 'ArrowLeft') {
      prev()
    }
    if (e.key === 'Enter') {
      dispatch('select', { name: hoveringMoon })
    }
  }

  let element

  onMount(() => {
    const draggable = interact(element).styleCursor(false).draggable({
      listeners: {
        move(e){
          dx -= e.dx
          dx = Math.max(-50, Math.min(50, dx))
        },
        end(e){
          if (Math.abs(dx) > 40) {
            dx < 0 ? prev() : next()
          }
          dx = 0
        }
      }
    })
    return () => {
      draggable.unset()
    }
  })

</script>

<nav>
  <div class="moon-selector-menu" style:--item-width={`${itemWidth}px`} role="menu" on:keydown={onkey} tabindex="0" bind:this={element}>
    <ul style:--rot={`${rot}deg`}>
      {#each menuItems as item, i}
        <!-- svelte-ignore a11y-click-events-have-key-events -->
        <li style:--offset={`${i * segmentPct}%`} on:click={selectMoon(item)} role="menuitem" class:active={item.active}>
          {#if item.mask}
            <div class="moon-mask" style:--mask={`url(${item.mask})`} style:--scale={`${item.size}`}></div>
          {:else}
            <div class="moon" style:--scale={`${item.size}`}></div>
          {/if}
        </li>
      {/each}
    </ul>
  </div>
</nav>

<style lang="sass">
  // a pulse animation
  @keyframes pulse
    0%
      opacity: 1
    50%
      opacity: 0.7
    100%
      opacity: 1

  .moon-selector-menu
    --circle-size: 400px
    --item-width: 60px
    display: flex
    width: 100%
    padding: 60px 0
    // overflow: hidden
    // mask-image: linear-gradient(90deg, rgba(0,0,0,0) 10%, rgba(0,0,0,1) 55%, rgba(0,0,0,1) 55%, rgba(0,0,0,0) 90%)
    mask-image: radial-gradient(ellipse, rgba(0,0,0,1) 5%, rgba(0,0,0,1) 15%, rgba(0,0,0,0) 80%)
    cursor: pointer
    ul, li
      list-style: none
      padding: 0
      margin: 0
    ul
      --rot: 0deg
      flex: 1
      position: relative
      height: 50px
      font-size: 20px
      height: 70px
      transform-origin: center calc(var(--circle-size) + 50%)
      transform: rotateZ(calc(270deg - var(--rot)))
      transition: transform 300ms ease

    li
      --offset: 0%
      position: relative
      // circle path
      offset-path: circle(var(--circle-size) at center calc(var(--circle-size) + 50%))
      offset-distance: var(--offset)
      display: flex
      justify-content: center
      align-items: center
      flex: 0 0 auto
      width: var(--item-width)
      transition: width 300ms ease

      &.active
        // width: 150px
        .moon, .moon-mask
          background: hsla(0, 0%, 100%, 0.95)
          transform: scale(calc(var(--scale) * 0.5 + 0.5))
          animation: pulse 1.6s infinite

    .moon
      --scale: 0
      border-radius: 50%
      background: hsla(0, 0%, 100%, 0.6)
      transition: transform 300ms, background 300ms
      width: 70px
      height: 70px
      transform: scale(var(--scale))
    .moon-mask
      --scale: 1
      --mask: none
      background: hsla(0, 0%, 100%, 0.6)
      transition: transform 300ms, background 300ms
      width: 70px
      height: 70px
      mask: var(--mask) center / contain luminance
      transform: scale(var(--scale))
</style>