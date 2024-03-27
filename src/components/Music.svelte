<script>
  import { Howl } from 'howler'
  import { onMount } from 'svelte'
  import songPath from '../assets/music/ES_Stay in Orbit - Victor Lundberg.mp3'
  import { musicOn } from '../store/environment'
  import { get } from 'svelte/store'

  let volume = 0.75
  const sound = new Howl({
    src: [songPath],
    autoplay: true,
    loop: true,
    volume,
    // html5: true,
  })

  onMount(() => {
    if (!get(musicOn)) {
      sound.volume(0)
    }

    const unsub = musicOn.subscribe((value) => {
      if (value) {
        sound.fade(0, volume, 4000)
      } else {
        sound.fade(volume, 0, 2000)
      }
    })

    return () => {
      sound.stop()
      unsub()
    }
  })
</script>