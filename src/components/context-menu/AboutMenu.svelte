<script>
import { planet, selectedMoon } from '../../store/environment'
import solarEclipseDiagram from '../../assets/Solar Eclipse Illo.svg'
import Icon from '@iconify/svelte'

let aboutLabOpen = false
</script>

<section class="about">
  {#if aboutLabOpen}
  <h2 class="heading">
    The MinuteLabs Eclipse Explorer
  </h2>
  <div class="content scrollbars">
    <p>
      In the real world, <em>looking directly at the Sun is a very bad idea and could
      cause permanent damage to your eyes</em>. But in this lab, you can safely observe
      solar eclipses on different planets in our solar system.
    </p>
    <p>
      This Eclipse Explorer simulates solar eclipses on different planets in our solar system.
      Each planet's unique atmosphere, and moons, affect how a solar eclipse looks
      from the surface.
    </p>
    <h3>Controls</h3>
    <p>
      You can use the controls to pan, zoom, and animate the eclipse. You can change
      the speed of the animation using the <u><Icon icon="mdi:speedometer" inline/> Speed Slider</u>.
      Tuning it to the middle will animate the eclipse with realistic timing.
      The <u><Icon icon="material-symbols-light:clear-night" inline/> Moon Distance Slider</u> controls the range of distances the moon
      can be from the planet. The <u><Icon icon="material-symbols-light:clear-day" inline/> Time of Day Slider</u> controls the
      position of the Sun in the sky. The <u><Icon icon="mdi:telescope" inline/> Telescope Mode</u> button lets you zoom in on the
      eclipse, where you can use the <u><Icon icon="ion:glasses" inline/> Exposure Slider</u> to adjust the amount of light the "camera"
      is capturing. To disable the music and more, check the <u><Icon icon="material-symbols:settings" inline/> Settings</u> menu.
    </p>
    <h3>
      What is a Solar Eclipse?
    </h3>
    <figure>
      <img src={solarEclipseDiagram} alt="Solar Eclipse Diagram" />
      <figcaption>
        A solar eclipse occurs when the moon passes between the Sun and the earth,
        blocking the Sun's light and casting a shadow on the earth.
        (Diagram not to scale.)
      </figcaption>
    </figure>
    <p>
      A solar eclipse occurs when a moon passes between a planet and the sun,
      temporarily blocking sunlight and casting a shadow on a planet.
      Depending on the distance of the sun and moon from the planet, you might
      see a partial eclipse where only part of the sun is covered; or a total
      eclipse where the sun is completely covered for a short time.
    </p>
    <p>
      To learn more about eclipses, watch MinuteEarth's video all about them.
    </p>
    <h3>
      Accuracy of the Simulation
    </h3>
    <p>
      We've done our best to make this simulation as accurate as possible, but there
      are some limitations. For example, the shadows of the moons are simplified
      to make the simulation run faster. This means that the shadows may not look
      exactly like they would in real life. For some moons and planets especially you
      may see layers of circles in the sky, which is not how a real eclipse would look.
    </p>
    <p>
      The atmospheres of planets are tricky to simulate accurately. For Earth and Mars,
      we have pictures so we can compare our simulation to reality. For the other planets,
      we have to rely on what we know about their atmospheres, and make educated guesses
      about how the light would scatter in them.
      <a href="https://science.gsfc.nasa.gov/sci/bio/vincent.kofman" target="_blank">NASA's Vincent Kofman</a>,
      who specializes in simulating planetary atmospheres,
      helped us review the accuracy of the atmospheres... so we're pretty confident
      it's close to what we currently think is accurate.
    </p>
    <h3>Data and Credits</h3>
    <p>
      Developer: Jasper Palfree <br />
      UX Designer: Sarah Berman and Jasper Palfree <br />
      Interface Designer: Sarah Berman <br />
      Reviewers: Henry Reich, Vincent Kofman <br />
      Project Director: Sarah Berman <br />
      Music: "Stay in Orbit" by Victor Lundberg <br />
    </p>
    <p>
      This Product is supported by the NASA Heliophysics Education Activation Team
      (NASA HEAT), part of NASA's Science Activation portfolio.
    </p>
    <p>
      The material contained in this document is based upon work supported by a
      National Aeronautics And Space Administration (NASA) grant or cooperative
      agreement. Any questions, findings, conclusions or recommendations expressed
      in this materials are those of the author and do not necessarily reflect the
      views of NASA.
    </p>
    <p>
      MinuteLabs is a Neptune Studios venture produced by Jasper Palfree and is a
      hub for learning about the physics of our world through fun and inspiring
      web experiences.
    </p>
  </div>
  {:else}
  <h2 class="heading">
    <span>{$planet}</span>
    <span>{$selectedMoon}</span>
  </h2>
  <div class="content scrollbars">
    {#if $planet === 'earth'}
      <p>
        Earth: familiar, yes, but nonetheless beautiful. Hopefully this shows it
        in a new light. The Earth boasts the best total eclipses in the solar
        system. Our moon (called Luna, in case you didn't know) is just the right
        size and distance to cover the Sun perfectly. This allows us to see the
        Sun's corona &mdash; the outermost layer of the Sun's atmosphere &mdash;
        in its full glory without the Sun's core overwhelming our vision.
      </p>
    {/if}
    {#if $planet === 'mars'}
      <p>
        Mars is a dusty place. It has an atmosphere, but the air is very thin.
        The air pressure is about 0.6% of Earth's. The air scatters the sunlight
        just like on Earth, and it would look blue if not for the dust. The dust
        is mainly iron oxide, which reflects more red light than blue. On the ground
        this dust gives Mars its red color, but if you move the time of day slider,
        you'll see that when the Sun is low, the sky is blue. This is because the
        iron oxide dust scatters more blue light in the forward direction than it
        does red light. This effect is subtle though, so you see it most when
        the light has to pass through a lot of dust, which happens when the Sun
        is near the horizon.
      </p>
      <p>
        Mars has two moons: Phobos and Deimos. Phobos looks small in the sky
        compared to the Sun, so it won't eclipse the Sun very much. But you can
        still see the light from the Sun dim a bit when Phobos passes in front
        of it. NASA actually captured photos of Phobos eclipsing the Sun from
        the surface of Mars. A quick internet search will show you some of these photos,
        which hopefully this Lab replicates well.
      </p>
    {/if}
    {#if $planet === 'jupiter'}
      <p>
        Jupiter, the Giant. The largest planet in our neighborhood. The Sun
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
        smaller moon). The Galilean moons all look larger than the Sun does
        in the sky, but Callisto is the right size and distance to still see
        some of the corona.
      </p>
    {/if}
    {#if $planet === 'saturn'}
      <p>
        Saturn. And before you ask, yes, the rings are visible. Move the Sun
        past the horizon to reveal the stary sky, and the spectacular rings.
        Saturn's atmosphere is similar to Jupiter's. Hydrogen, Helium, ammonia clouds,
        and haze. There isn't a solid
        place to stand, so we'll float in the atmosphere where it's 1 Bar of pressure;
        about the same as Earth's surface.
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
        is a beautiful place and it has rings too! There isn't a solid
        place to stand, so we'll float in the atmosphere where it's 1 Bar of pressure;
        about the same as Earth's surface.
        The Sun is hard to see... if you lose
        track of it, double tap the Sun to recenter it and zoom in a bit. The sky
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
        Neptune is the farthest planet, and the Sun looks like a bright star.
        In many pictures of Neptune, it looks like a deep blue color. But
        recent updates suggest that it looks very similar to Uranus. That
        makes sense, since they're both gas giants with similar atmospheres.
        The clouds are made of methane.
        There isn't a solid
        place to stand, so we'll float in the atmosphere where it's 1 Bar of pressure;
        about the same as Earth's surface.
      </p>
      <p>
        Since the Sun is so far away, most of its closest moons just
        dwarf the Sun in the Neptunian sky. But Nereid is small enough
        and far enough away that it's almost reminiscent of Phobos eclipsing
        the Sun on Mars... if you zoom in a lot, that is.
      </p>
    {/if}
  </div>
  {/if}
  <div class="footer">
    <p class="made-possible">
      Eclipse Explorer was made possible by MinuteEarth and the NASA Heliophysics Education Activation Team (NASA HEAT).
    </p>
    <p class="cta centered">
      <button on:click={() => aboutLabOpen = !aboutLabOpen}>
        {aboutLabOpen ? 'About this Planet' : 'More About this Lab'}
      </button>
    </p>
  </div>
</section>

<style lang="sass">
  .about
    color: white
    font-size: 14px
    font-weight: 400
    height: 100%
    padding: 1.5rem 0.5rem
    display: flex
    flex-direction: column
    p
      line-height: 1.5
  .content
    overflow-y: auto
    flex: 1
    margin: 0 -0.85rem
    padding: 0 0.85rem
    h3
      font-size: 16px
      font-weight: 400
      line-height: 20px
      text-align: center
    u
      text-decoration: none
      border-bottom: 2px solid #d5d5d5
    a
      color: white
      text-decoration: underline
  .heading
    display: flex
    justify-content: space-between
    font-size: 10px
    font-weight: 400
    margin: 0
    margin-bottom: 1.5em
    text-transform: uppercase
  .footer
    margin-top: auto
  .footer .made-possible
    font-size: 11px
    color: hsla(0, 0%, 75%, 1)
  .header::after,
  .footer::before
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
  button,
  .button
    display: inline-block
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
figure
  margin: 2em 10%
  text-align: center
  img
    margin: auto
    width: 100%
    max-width: 420px
  figcaption
    text-align: left
    font-size: 0.85em
    margin: 1.5em 0
</style>