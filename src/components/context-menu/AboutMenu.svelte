<script>
import { planet, selectedMoon } from '../../store/environment'

let aboutLabOpen = false
</script>

<section class="about">
  <div class="header">
    <p>This lab was made possible by... lorem ipsum</p>
    <p class="cta centered">
      <button on:click={() => aboutLabOpen = !aboutLabOpen}>
        {aboutLabOpen ? 'About this Planet' : 'More About this Lab'}
      </button>
    </p>
  </div>
  {#if aboutLabOpen}
  <h2 class="heading">
    MinuteLabs Eclipse Simulator
  </h2>
  <div class="content">
    <p>about lab</p>
  </div>
  {:else}
  <h2 class="heading">
    <span>{$planet}</span>
    <span>{$selectedMoon}</span>
  </h2>
  <div class="content">
    {#if $planet === 'earth'}
      <p>
        Earth: familiar, yes, but nonetheless beautiful. Hopefully this shows it
        in a new light. The Earth boasts the best total eclipses in the solar
        system. Our moon (called Luna, in case you didn't know) is just the right
        size and distance to cover the sun perfectly. This allows us to see the
        sun's corona &mdash; the outermost layer of the sun's atmosphere &mdash;
        in its full glory.
      </p>
    {/if}
    {#if $planet === 'mars'}
      <p>
        Mars is a dusty place. It has an atmosphere, but the air is very thin.
        The air pressure is about 0.6% of Earth's. The air scatters the sunlight
        just like on Earth, and it would look blue if not for the dust. The dust
        is mainly iron oxide, which reflects more red light than blue. On the ground
        this dust gives Mars its red color, but if you move the time of day slider,
        you'll see that when the sun is low, the sky is blue. This is because the
        iron oxide dust scatters more blue light in the forward direction than it
        does red light. This effect is subtle though, so you see it most when
        the light has to pass through a lot of dust, which happens when the sun
        is near the horizon.
      </p>
      <p>
        Mars has two moons, Phobos and Deimos. Phobos looks small in the sky
        compared to the sun, so it won't eclipse the sun very much. But you can
        still see the light from the sun dim a bit when Phobos passes in front
        of it. NASA actually captured photos of Phobos eclipsing the sun from
        the surface of Mars. A quick search will show you some of these photos,
        which hopefully this Lab replicates well.
      </p>
    {/if}
    {#if $planet === 'jupiter'}
      <p>
        Jupiter, the Giant. The largest planet in our neighborhood. The sun
        is starting to look much smaller and farther away now. We don't
        have a solid surface to stand on here. Instead we'll have to hover in
        Jupiter's cloudy atmosphere at an altitude where the air pressure is about
        the same as Earth's (around 1 Bar). The Hydrogen and Helium in Jupiter's
        atmosphere scatter sunlight in a similar way to Earth's atmosphere, but
        the atmosphere is hazy and cloudy, so the familiar "sky blue" color
        is muted. The clouds are made of ammonia crystals,
        which look similar to water clouds on Earth.
      </p>
      <p>
        Jupiter has... a lot of moons. But the big ones are called the Galilean moons.
        These are the four included in this Lab (plus Amalthea as an example of a
        smaller moon). The Galilean moons all look larger than the sun does
        in the sky, but Callisto is the right size and distance to still see
        some of the corona.
      </p>
    {/if}
    {#if $planet === 'saturn'}
      <p>
        Saturn. And before you ask, yes, the rings are visible. Move the sun
        past the horizon to reveal the stary sky, and the spectacular rings.
        Saturn's atmosphere is similar to Jupiter's. Hydrogen, Helium, ammonia clouds,
        and haze.
      </p>
      <p>
        Saturn also has many moons, but the big ones are Titan and Rhea. The moons
        are about the right size where the eclipse really starts to look like a
        shadow passing over you in the sky. Zoom out to see this better.
      </p>
      <p>
        You may also start to see some places where the simulation breaks down
        a bit. Mimas, for example, is so close to Saturn that the way we're
        simulating the shadows doesn't work very well. It looks like a bunch
        of circles in the sky... but the real eclipse wouldn't look like that.
      </p>
    {/if}
    {#if $planet === 'uranus'}
      <p>
        This poor planet is always the butt of a lot of jokes and puns. But it really
        is a beautiful place and it has rings too! Again, there isn't a solid
        place to stand, so we'll
        keep floating at 1 Bar of pressure. The sun is hard to see... if you lose
        track of it, double tap the sun to recenter it and zoom in a bit. The sky
        during the day is a beautiful blue-green color. This is mainly due to
        the methane in Uranus's atmosphere. The methane clouds aren't too shabby
        either.
      </p>
      <p>
        There are lots of moons to choose from. And again, like Saturn, you may
        see the simulation break down a bit with some of the moons.
      </p>
    {/if}
    {#if $planet === 'neptune'}
      <p>
        Neptune is the farthest planet, and the sun looks like a bright star.
        In many pictures of Neptune, it looks like a deep blue color. But
        recent updates suggest that it looks very similar to Uranus. That
        makes sense, since they're both gas giants with similar atmospheres.
        Again, enjoy the methane clouds.
      </p>
      <p>
        Since the sun is so far away, most of its closest moons just
        dwarf the sun in the Neptunian sky. But Nereid is small enough
        and far enough away that it's almost reminiscent of Phobos eclipsing
        the sun on Mars... if you zoom in a lot, that is.
      </p>
    {/if}
  </div>
  {/if}
</section>

<style lang="sass">
  .about
    color: white
    font-size: 14px
    font-weight: 400
    height: 100%
    padding: 1.5rem 0.5rem
    p
      line-height: 1.5
  .heading
    display: flex
    justify-content: space-between
    font-size: 10px
    font-weight: 400
    margin: 0
    margin-bottom: 1.5em
    text-transform: uppercase
  .header
    &::after
      content: ''
      display: block
      height: 1px
      width: 90%
      margin: 1.5em 0.9em
      background: hsla(0, 0%, 100%, 0.3)
  .centered
    text-align: center
  .cta
    margin: 1.5em 0
  button
    background: none
    color: white
    font-size: 13px
    text-transform: uppercase
    font-weight: 400
    cursor: pointer
    padding: .3em 1.1em
    margin: 0
    border: 1px solid hsla(0, 0%, 100%, 1)
    border-radius: 15px
    transition: background 0.2s
    &:hover
      background: hsla(0, 0%, 100%, 0.1)
    &:active
      background: hsla(0, 0%, 100%, 0.2)
</style>