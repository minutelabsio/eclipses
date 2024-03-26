<script>
  import * as PlanetConfigs from '../configs'
  import interact from 'interactjs'
  import { onMount } from 'svelte'

  export let planet = 'earth'
  export let hoveringMoon = 'luna'

  const selectedItemWidth = 80
  const itemWidth = 80

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
  <div class="moon-selector-menu" style:--item-width={`${itemWidth}px`} role="menu" on:keydown={onkey} tabindex="0" bind:this={element}>
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
  // a pulse animation
  @keyframes pulse
    0%
      opacity: 1
    50%
      opacity: 0.7
    100%
      opacity: 1

  .moon-selector-menu
    --item-width: 60px
    display: flex
    width: 100%
    overflow: hidden
    mask-image: linear-gradient(90deg, rgba(0,0,0,0) 10%, rgba(0,0,0,1) 50%, rgba(0,0,0,0) 90%)
    cursor: pointer
    ul, li
      list-style: none
      padding: 0
      margin: 0
    ul
      flex: 1
      position: relative
      right: calc(var(--item-width) / 2)
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
      width: var(--item-width)
      transition: width 300ms ease

      &.active
        // width: 150px
        .moon
          background: hsla(0, 0%, 100%, 0.75)
          transform: scale(calc(var(--scale) * 0.5 + 0.5))
          animation: pulse 1.6s infinite

    .moon
      --scale: 0
      border-radius: 50%
      background: hsla(0, 0%, 100%, 0.3)
      transition: transform 300ms, background 300ms
      width: 60px
      height: 60px
      transform: scale(var(--scale))
      cursor: pointer
</style>