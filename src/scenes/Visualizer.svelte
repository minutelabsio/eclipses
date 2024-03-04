<script>
  import { AudioAnalyser, MathUtils } from 'three'
  import { Easing, Tween } from 'intween'
  import FileDrop from "filedrop-svelte"
  import Stats from '../components/Stats.svelte'
  import { T, useThrelte, useFrame } from '@threlte/core'
  import { AudioListener, Audio } from '@threlte/extras'
  import Sky from '../entities/Sky.svelte'
  import Renderer from '../components/Renderer.svelte'
  import DebugControls from '../components/DebugControls.svelte'
  import { eclipseProgress, elevation, totalityFactor, doAnimation, moonRightAscention, cloudMie, cloudThickness, windSpeed } from '../store/environment'
  import {
    DEG,
    METER,
    AU,
  } from '../lib/units'
  import Levetate from '../components/Levetate.svelte'

  const { size } = useThrelte()
  let files = {}
  let audio
  let player = null
  let isPlaying = false
  let currentTime = 0

  const play = () => {
    player.play()
    isPlaying = true
  }

  const pause = () => {
    player.pause()
    isPlaying = false
  }

  const handleDrop = (e) => {
    files = e.detail.files
    const file = files.accepted[0]
    const reader = new FileReader()
    reader.onload = (e) => {
      const data = e.target.result
      // now setup audiobuffer
      const context = new AudioContext()
      context.decodeAudioData(data, (buffer) => {
        audio = buffer
      })
    }
    reader.readAsArrayBuffer(file)
  }

  $: analyzer = player && new AudioAnalyser(player, 2048)

  const runningAverage = (win) => {
    const buf = []
    const push = (val) => {
      buf.push(val)
      if (buf.length > win) {
        buf.shift()
      }
    }
    const average = () => {
      return buf.reduce((a, b) => a + b, 0) / buf.length
    }
    return { push, average }
  }

  const getFreqIndex = (freq, sampleRate, fftSize) => {
    const nyquist = sampleRate / 2
    return Math.floor((freq / nyquist) * (fftSize / 2))
  }

  const freqDataSubset = (data, low, hi) => {
    const lowIndex = getFreqIndex(low, 48000, 2048)
    const hiIndex = getFreqIndex(hi, 48000, 2048)
    return data.slice(lowIndex, hiIndex)
  }

  const binByPowerScale = (data, low, hi) => {
    const out = []
    let i = low
    let next = low * 2
    while (next < hi) {
      let from = getFreqIndex(i, 48000, 2048)
      let to = getFreqIndex(next, 48000, 2048)
      let subset = data.slice(from, to)
      let sum = subset.reduce((a, b) => a + b, 0)
      out.push(sum / subset.length)
      i = next
      next = next * 2
    }
    return out
  }

  const getBarData = (data, startWidth, freqLow, freqHi) => {
    const out = []
    for (let i = 0; i < data.length; i++) {
      let pos = Math.log2(i + 1) * startWidth
      let width = Math.log2(i + 2) * startWidth - pos
      let freq = (freqHi - freqLow) * (i / data.length) + freqLow
      out.push({
        pos,
        width,
        height: data[i] / 255,
      })
    }
    return out
  }

  const state = {
    mie: runningAverage(12),
    elevation: runningAverage(4 * 60),
    speed: runningAverage(4),
  }

  let frequencydata = []
  let barData = []

  useFrame(() => {
    if (analyzer) {
      const data = analyzer.getFrequencyData()
      frequencydata = freqDataSubset(data, 30, 20000)
      barData = getBarData(frequencydata, 0.5, 30, 20000)
      // frequencydata = binByPowerScale(data, 30, 20000)
      state.mie.push(data[6] / 255)
      // state.mie.push(data[1] / 255)
      // state.mie.push(data[2] / 255)
      state.elevation.push(data[0] / 255)
      state.speed.push(data[10] / 255)
      windSpeed.set(state.speed.average() * 100)
      elevation.set(state.elevation.average() * 30)
      cloudThickness.set(state.mie.average() * 1)
    }
  })

  moonRightAscention.set(-1)
</script>
<style lang="sass">
  .filedrop
    position: absolute
    bottom: 0
    left: 0
    right: 400px
    padding: 20px
    background: rgba(255, 255, 255, 0.1)
    display: flex
    flex-direction: row
    justify-content: space-around
</style>

<Levetate>
  <div class="filedrop">
    <div>
    {#if files.accepted}
    <h3>Accepted files</h3>
    <ul>
      {#each files.accepted as file}
        <li>{file.name}</li>
      {/each}
    </ul>
    {/if}
    </div>
    <FileDrop on:filedrop={handleDrop}/>
    {#if player}
    <div class="controls">
      <!-- play/pause button and playback time -->
      {#if isPlaying}
        <button on:click={pause}>Pause</button>
      {:else}
        <button on:click={play}>Play</button>
      {/if}
    </div>
    {/if}
  </div>
</Levetate>

<DebugControls />
<Renderer/>
<Stats />

<T.OrthographicCamera args={[-$size.width / 2, $size.width / 2, $size.height / 2, -$size.height / 2, 1, 10]}>
  <AudioListener id="audio" />
</T.OrthographicCamera>

<!-- <T.Group>
  {#each barData as value, i}
    <T.Mesh
      position={[value.pos - 2, 0, -1]}
      scale={[value.width, value.height, 0.1]}
      renderOrder={2}
    >
      <T.BoxGeometry args={[1, 1, 1]} />
      <T.MeshBasicMaterial color="red" />
    </T.Mesh>
  {/each}
</T.Group> -->

<!-- Concentric ring visual -->
<T.Group rotation={[-1, 0, 0]}>
  {#each barData as value, i}
    <T.Mesh
      renderOrder={2}
      position={[0, 0, value.height]}
    >
      <T.RingGeometry args={[value.pos, value.pos + value.width, 64]} />
      <T.MeshBasicMaterial color="red" transparent opacity={value.height} />
    </T.Mesh>
  {/each}
</T.Group>

<!-- Sky -->
<Sky fisheye={true}/>

<!-- Audio -->
{#if audio}
  <Audio id="audio" src={audio} bind:ref={player}/>
{/if}