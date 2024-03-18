<script>
  import { derived, writable } from 'svelte/store'
  import { createEventDispatcher } from 'svelte'
  import Icon from '@iconify/svelte'
  import TimeOfDayMenu from './context-menu/TimeOfDayMenu.svelte'
  import PlaybackSpeedMenu from './context-menu/PlaybackSpeedMenu.svelte'

  export let dispatch = createEventDispatcher()

  const isTab = (item) => !item.isButton && !item.isToggle
  const menuItems = writable([
    {
      icon: 'mdi:orbit',
      name: 'planet',
      title: 'Planet View',
      isButton: true,
    },
    {
      icon: 'mdi:telescope',
      name: 'telescope',
      title: 'Telescope View',
      isToggle: true,
    },
    {
      icon: 'mdi:sun-angle',
      name: 'sun',
      title: 'Time of day',
      component: TimeOfDayMenu,
      active: true
    },
    {
      icon: 'mdi:speedometer',
      name: 'animation-speed',
      title: 'Animation Speed',
      component: PlaybackSpeedMenu,
    },
    {
      icon: 'mdi:information',
      name: 'info',
      title: 'Info',
      expanded: true,
    },
    {
      icon: 'mdi:gear',
      name: 'settings',
      title: 'Settings',
      expanded: true,
    },
  ])
  const activeItem = derived(
    menuItems,
    $menuItems => $menuItems.filter(isTab).find(item => item.active)
  )

  export const selected = derived(
    activeItem,
    $activeItem => $activeItem?.name
  )

  const buttonClicked = (name) => {
    const itemClicked = $menuItems.find(item => item.name === name)
    if (isTab(itemClicked)) {
      if (itemClicked.active && itemClicked.expanded) {
        // select time of day
        menuItems.update(items => {
          items.filter(isTab).forEach(item => {
            item.active = item.name === 'sun'
          })
          return items
        })
        dispatch('select', 'sun')
        dispatch('timeOfDay')
        return
      }
      menuItems.update(items => {
        items.filter(isTab).forEach(item => {
          item.active = item.name === name
        })
        return items
      })
      dispatch('select', name)
    } else if (itemClicked.isToggle) {
      itemClicked.active = !itemClicked.active
      menuItems.update(i => i)
      dispatch('toggle', name)
    }
    dispatch(name)
  }
</script>

<nav class="eclipse-menu">
  <div class="context-menu" class:expanded={$activeItem?.expanded}>
    {#if $activeItem?.component}
    <svelte:component this={$activeItem.component}/>
    {/if}
  </div>
  <ul>
    {#each $menuItems as item}
      <li>
        <button on:click={() => buttonClicked(item.name)} class:active={item.active}>
          <Icon icon={item.icon} />
          <span class="sr-only">{item.title}</span>
        </button>
      </li>
    {/each}
  </ul>
</nav>

<style lang="sass">
  .eclipse-menu
    .context-menu
      height: 40px
      display: flex
      flex-direction: column
      justify-content: center
      padding: 0 1.5rem
      margin: 0 6px
      letter-spacing: 1px
      background: linear-gradient(-5deg, rgba(221, 221, 221, 0.15) 7.59%, rgba(221, 221, 221, 0.3) 102.04%)
      backdrop-filter: blur(10px)
      border-radius: 10px 10px 0 0
      transition: height 300ms
      &.expanded
        height: 280px
      &.collapsed
        height: 0
    ul, li
      display: flex
      list-style: none
      padding: 0
      margin: 0
    ul
      display: flex
      justify-content: space-around
      align-items: center
      font-size: 20px
      height: 70px
      padding: 0 0.5rem
      background: linear-gradient(10deg, rgba(221, 221, 221, 0.15) 7.59%, rgba(221, 221, 221, 0.5) 102.04%)
      backdrop-filter: blur(10px)
      li
        button
          line-height: 0
          border: none
          padding: 0
          margin: 0
          cursor: pointer
          border-radius: 50%
          background: hsla(0, 0%, 100%, 0)
          width: 50px
          height: 50px
          color: hsla(0, 0%, 100%, .6)
          font-size: 1.5em
          transition: transform 100ms, color 150ms
          transform-origin: 50% 50%
          border: 1px solid hsla(0, 0%, 100%, 0)
          &:focus, &:hover
            color: hsla(0, 100%, 100%, 1)
          &:active
            color: hsla(0, 0%, 100%, .6)
          &.active
            border: 1px solid hsla(0, 0%, 100%, 0.25)
            background: hsla(0, 0%, 100%, 0.25)
            color: hsla(0, 100%, 100%, 1)
</style>