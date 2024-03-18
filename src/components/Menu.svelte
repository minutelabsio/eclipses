<script>
  import { createEventDispatcher } from 'svelte'
  import Icon from '@iconify/svelte'

  export let dispatch = createEventDispatcher()

  const menuItems = [
    {
      icon: 'mdi:planet',
      name: 'planet',
      title: 'Planet View',
    },
    {
      icon: 'mdi:sun-angle',
      name: 'sun',
      title: 'Time of day',
    },
    {
      icon: 'mdi:telescope',
      name: 'telescope',
      title: 'Telescope View',
    },
    {
      icon: 'mdi:speedometer',
      name: 'animation-speed',
      title: 'Animation Speed',
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
  ]

  const buttonClicked = (name) => {
    dispatch(name)
    dispatch('select', name)
  }
</script>

<nav class="eclipse-menu">
  <ul>
    {#each menuItems as item}
      <li>
        <button on:click={() => buttonClicked(item.name)}>
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
    ul, li
      display: flex
      list-style: none
      padding: 0
      margin: 0
    ul
      display: flex
      height: 100%
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
</style>