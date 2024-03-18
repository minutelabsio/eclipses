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
    },
    {
      icon: 'mdi:gear',
      name: 'settings',
      title: 'Settings',
    },
  ])
  const activeItem = derived(
    menuItems,
    $menuItems => $menuItems.filter(isTab).find(item => item.active)
  )

  const buttonClicked = (name) => {
    const itemClicked = $menuItems.find(item => item.name === name)
    if (isTab(itemClicked)) {
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
  <div class="context-menu">
    {#if $activeItem.component}
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
    height: 100%
    display: flex
    flex-direction: column
    .context-menu
      flex: 1
      height: 50%
      display: flex
      flex-direction: column
      justify-content: center
      padding: 0 64px
    ul, li
      display: flex
      list-style: none
      padding: 0
      margin: 0
    ul
      display: flex
      flex: 1
      justify-content: space-around
      align-items: center
      font-size: 20px
      li
        button
          line-height: 0
          background: none
          border: none
          padding: 0
          margin: 0
          cursor: pointer
          color: white
          font-size: 1.5em
          transition: transform 100ms
          transform-origin: 50% 50%
          &:focus, &:hover
            transform: scale(1.2)
          &:active
            transform: scale(1)
          &.active
            color: #3eedda
</style>