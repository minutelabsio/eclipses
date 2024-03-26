<script>
  import { derived, writable } from 'svelte/store'
  import { createEventDispatcher } from 'svelte'
  import Icon from '@iconify/svelte'
  import TimeOfDayMenu from './context-menu/TimeOfDayMenu.svelte'
  import PlaybackSpeedMenu from './context-menu/PlaybackSpeedMenu.svelte'
  import AboutMenu from './context-menu/AboutMenu.svelte'
  import SettingsMenu from './context-menu/SettingsMenu.svelte'
  import { telescopeMode } from '../store/environment'

  export let dispatch = createEventDispatcher()

  const isTab = (item) => !item.isButton && !item.isToggle
  const menuItems = writable([
    {
      icon: 'material-symbols:motion-photos-on-rounded',
      name: 'planet',
      title: 'Planet View',
      isButton: true,
    },
    {
      // icon: 'mdi:telescope',
      icon: 'material-symbols:center-focus-strong-outline',
      iconOn: 'material-symbols:center-focus-strong',
      name: 'telescope',
      title: 'Telescope View',
      isToggle: true,
    },
    {
      icon: 'material-symbols:wb-twilight-outline-rounded',
      iconOn: 'material-symbols:wb-twilight-rounded',
      name: 'sun',
      title: 'Time of day',
      component: TimeOfDayMenu,
      active: true
    },
    {
      icon: 'material-symbols:swap-driving-apps-wheel-outline',
      iconOn: 'material-symbols:swap-driving-apps-wheel',
      name: 'animation-speed',
      title: 'Animation Speed',
      component: PlaybackSpeedMenu,
    },
    {
      icon: 'material-symbols:settings-outline-rounded',
      iconOn: 'material-symbols:settings-rounded',
      name: 'settings',
      title: 'Settings',
      component: SettingsMenu,
      expanded: true,
    },
    {
      icon: 'material-symbols:info-outline-rounded',
      iconOn: 'material-symbols:info-rounded',
      name: 'info',
      title: 'Info',
      component: AboutMenu,
      expanded: true,
    },
  ])

  telescopeMode.subscribe(value => {
    menuItems.update(items => {
      items.find(item => item.name === 'telescope').active = value
      return items
    })
  })

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
      // if (itemClicked.active && itemClicked.expanded) {
      //   // select time of day
      //   menuItems.update(items => {
      //     items.filter(isTab).forEach(item => {
      //       item.active = item.name === 'sun'
      //     })
      //     return items
      //   })
      //   dispatch('select', 'sun')
      //   dispatch('timeOfDay')
      //   return
      // }
      menuItems.update(items => {
        items.filter(isTab).forEach(item => {
          item.active = item.name === name && !item.active
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
  <div class="context-menu" class:expanded={$activeItem?.expanded} class:collapsed={!$activeItem}>
    {#if $activeItem?.component}
    <svelte:component this={$activeItem.component}/>
    {/if}
  </div>
  <ul>
    {#each $menuItems as item}
      <li>
        <button on:click={() => buttonClicked(item.name)} class:active={item.active}>
          <Icon icon={item.active ? item.iconOn : item.icon} />
          <span class="sr-only">{item.title}</span>
        </button>
      </li>
    {/each}
  </ul>
</nav>

<style lang="sass">
  .eclipse-menu
    font-family: "Plus Jakarta Sans", sans-serif
    .context-menu
      height: 40px
      display: flex
      flex-direction: column
      justify-content: center
      padding: 0 1.5rem
      margin: 0 6px
      letter-spacing: 1px
      background: linear-gradient(-5deg, rgba(125, 125, 125, 0.5) 7.59%, rgba(125, 125, 125, 0.8) 102.04%)
      -webkit-backdrop-filter: blur(10px)
      backdrop-filter: blur(10px)
      border: 1px solid hsla(0, 0%, 100%, 0)
      border-radius: 10px 10px 0 0
      transition: height 300ms
      &.expanded
        height: 380px
        border: 1px solid hsla(0, 0%, 100%, 0.3)
        border-bottom: 0
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
      background: linear-gradient(10deg, rgba(125, 125, 125, 0.5) 7.59%, rgba(125, 125, 125, 0.8) 102.04%)
      -webkit-backdrop-filter: blur(10px)
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
          color: hsla(0, 0%, 100%, .5)
          font-size: 1.5em
          transition: transform 100ms, color 150ms
          transform-origin: 50% 50%
          border: 1px solid hsla(0, 0%, 100%, 0)
          &:focus, &:hover
            color: hsla(0, 100%, 100%, 1)
          &:active
            color: hsla(0, 0%, 100%, .7)
          &.active
            border: 1px solid hsla(0, 0%, 100%, 0.25)
            background: hsla(0, 0%, 100%, 0.25)
            color: hsla(0, 100%, 100%, .8)
</style>