<script>
  import { derived, writable } from 'svelte/store'
  import { createEventDispatcher, onMount } from 'svelte'
  import Icon from '@iconify/svelte'
  import TimeOfDayMenu from './context-menu/TimeOfDayMenu.svelte'
  import PlaybackSpeedMenu from './context-menu/PlaybackSpeedMenu.svelte'
  import AboutMenu from './context-menu/AboutMenu.svelte'
  import SettingsMenu from './context-menu/SettingsMenu.svelte'

  export let telescope = false
  const dispatch = createEventDispatcher()

  const isTab = (item) => !item.isButton && !item.isToggle
  const menuItems = writable([
    {
      icon: 'material-symbols-light:motion-photos-on-rounded',
      name: 'planet',
      title: 'Planet View',
      isButton: true,
    },
    {
      // icon: 'mdi:telescope',
      icon: 'mdi:telescope',
      iconOn: 'mdi:telescope',
      name: 'telescope',
      title: 'Telescope View',
      isToggle: true,
    },
    // {
    //   icon: 'fluent:weather-sunny-high-48-regular',
    //   iconOn: 'fluent:weather-sunny-high-48-filled',
    //   name: 'sun',
    //   title: 'Time of day',
    //   component: TimeOfDayMenu,
    //   active: true
    // },
    {
      icon: 'ion:ios-speedometer-outline',
      iconOn: 'ion:ios-speedometer',
      name: 'animation-speed',
      title: 'Animation Speed',
      component: PlaybackSpeedMenu,
      active: true,
    },
    {
      icon: 'material-symbols-light:settings-outline-rounded',
      iconOn: 'material-symbols-light:settings-rounded',
      name: 'settings',
      title: 'Settings',
      component: SettingsMenu,
      type: 'expanded',
    },
    {
      icon: 'material-symbols-light:info-outline-rounded',
      iconOn: 'material-symbols-light:info-rounded',
      name: 'info',
      title: 'Info',
      component: AboutMenu,
      type: 'full',
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
      menuItems.update(a => a)
      dispatch('toggle', name)
    }
    dispatch(name)
  }

  const checkTelescopeConditions = (telescope) => {
    menuItems.update(items => {
      items.forEach(item => {
        if (item.name === 'sun') {
          if (telescope){
            item.active = false
          }
          item.disabled = telescope
        } else if (item.name === 'telescope') {
          item.active = telescope
        }
      })
      return items
    })
  }

  $: checkTelescopeConditions(telescope)

  menuItems.subscribe(items => {
    const telescopeBtn = items.find(item => item.name === 'telescope')
    if (telescopeBtn.active !== telescope) {
      telescope = telescopeBtn.active
    }
  })

</script>

<nav class="eclipse-menu">
  <div class={'context-menu ' + $activeItem?.type} class:collapsed={!$activeItem}>
    {#if $activeItem?.component}
    <svelte:component this={$activeItem.component}/>
    {/if}
  </div>
  <ul>
    {#each $menuItems as item}
      <li>
        <button on:click={() => buttonClicked(item.name)} class:active={item.active} disabled={item.disabled}>
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
      border-radius: 20px 20px 0 0

      &.expanded,
      &.full
        max-height: 100vh
        height: 300px
        -webkit-backdrop-filter: blur(10px)
        backdrop-filter: blur(10px)
        background: linear-gradient(-5deg, rgba(128, 128, 128, 0.3) 7.59%, rgba(128, 128, 128, 0.8) 102.04%)
        border-bottom: 0
        transition: height 300ms
      &.full
        height: 80vh
        overflow-y: auto
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
      font-size: 40px
      height: 70px
      padding: 0 0.5rem
      border-radius: 10px 10px 0 0
      border: 1px solid hsla(0, 0%, 93%, 0.3)
      border-width: 1px 1px 0 1px
      background: linear-gradient(175deg, rgba(128, 128, 128, 0.36) 7.59%, rgba(128, 128, 128, 0.15) 102.04%)
      -webkit-backdrop-filter: blur(10px)
      backdrop-filter: blur(10px)
      @media screen and (max-width: 660px)
        border-radius: 0
        border-width: 1px 0 0 0
      li
        button
          line-height: 0
          border: none
          padding: 0
          margin: 0
          cursor: pointer
          border-radius: 50%
          background: hsla(0, 0%, 100%, 0)
          width: 1.4em
          height: 1.4em
          color: hsla(0, 0%, 100%, .5)
          font-size: 1em
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
          &:disabled
            color: hsla(0, 0%, 100%, 0.25)
            cursor: not-allowed
</style>