<script>
  import * as PlanetConfigs from '../configs'
  import interact from 'interactjs'
  import { onMount } from 'svelte'

  export let planet = 'earth'
  export let hoveringMoon = 'luna'

  const getMoonsFor = (planet) => {
    const moons = Object.entries(PlanetConfigs[planet].moons)
      .map(([name, cfg]) => ({ name, radius: cfg.moonRadius, distance: cfg.moonDistance }))
      .sort((a, b) => a.distance - b.distance)

    // largest moon
    const largest = moons.reduce((a, b) => a?.radius > b.radius ? a : b)
    return moons.map(moon => {
      return {
        name: moon.name,
        size: moon.radius / largest.radius,
        active: false
      }
    })
  }

  const getMenuItems = (moons, hoveringMoon) => {
    if (!moons.find(moon => moon.name === hoveringMoon)) {
      hoveringMoon = moons[0].name
      return moons
    }
    return moons.map(moon => {
      if (moon.name === hoveringMoon) {
        return { ...moon, active: true }
      }
      return moon
    })
  }

  const carouselPosition = (index, items) => {
    const selectedItemWidth = 150
    const itemWidth = 60
    index = Math.max(0, Math.min(index, items.length - 1))
    const offset = (index - 0.5) * itemWidth + selectedItemWidth / 2
    return offset
  }

  const selectMoon = (item) => () => {
    hoveringMoon = item.name
  }

  let dx = 0

  $: moons = getMoonsFor(planet)
  $: hoveringMoon = moons.find(m => m.name === hoveringMoon) ? hoveringMoon : moons[0].name
  $: menuItems = getMenuItems(moons, hoveringMoon)
  $: selectedIndex = menuItems.findIndex(item => item.active)
  $: position = carouselPosition(selectedIndex, menuItems) + dx

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
  <div class="moon-selector-menu" role="menu" on:keydown={onkey} tabindex="0" bind:this={element}>
    <ul style:transform={`translateX(-${position}px)`}>
      {#each menuItems as item}
        <!-- svelte-ignore a11y-click-events-have-key-events -->
        <li on:click={selectMoon(item)} role="menuitem" class:active={item.active} >
          <div class="moon" style:--scale={`${item.size}`}></div>
        </li>
      {/each}
    </ul>
  </div>
</nav>

<style lang="sass">
  .moon-selector-menu
    display: flex
    width: 100%
    background: linear-gradient(10deg, rgba(221, 221, 221, 0.15) 7.59%, rgba(221, 221, 221, 0.5) 102.04%)
    backdrop-filter: blur(10px)
    overflow: hidden
    ul, li
      list-style: none
      padding: 0
      margin: 0
    ul
      position: relative
      right: 30px
      display: flex
      height: 50px
      font-size: 20px
      height: 70px
      margin-left: 50%
      transition: transform 300ms ease
    li
      position: relative
      display: flex
      justify-content: center
      align-items: center
      flex: 0 0 auto
      width: 60px
      transition: width 300ms ease

      &.active
        width: 150px
        .moon
          background: hsla(0, 0%, 0%, 1)
          transform: scale(calc(var(--scale) * 0.5 + 0.5))

    .moon
      --scale: 0
      border-radius: 50%
      background: hsla(0, 0%, 100%, 0.3)
      transition: transform 300ms, background 300ms
      width: 50px
      height: 50px
      transform: scale(var(--scale))
      cursor: pointer
</style>