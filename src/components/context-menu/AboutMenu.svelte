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
      This Eclipse Explorer simulates solar eclipses on planets in our solar system.
      Each planet's atmosphere and moons affect how a solar eclipse looks from the surface.
    </p>
    <p>
      In the real world, <em>looking directly at the Sun with your bare eyes is a very bad idea and could
      cause permanent damage</em>. But good news! In this lab, you can safely observe
      solar eclipses on different planets in our solar system.
    </p>

    <h3>
      What is a Solar Eclipse?
    </h3>
    <figure>
      <img src={solarEclipseDiagram} alt="Solar Eclipse Diagram" />
      <figcaption>
        A solar eclipse occurs when a moon passes between the Sun and a planet,
        blocking the Sun's light and casting a shadow.
        (Diagram not to scale.)
      </figcaption>
    </figure>
    <p>
      A solar eclipse occurs when a moon passes between a planet and the Sun,
      temporarily blocking sunlight and casting a shadow on a planet. Depending
      on the distance of the sun and moon from the planet, you might see a partial
      eclipse where only part of the Sun is covered; or a total eclipse where the Sun
      is completely covered for a short time.
    </p>
    <p>
      To learn more about eclipses, watch MinuteEarth's video all about them.
    </p>

    <h3>Controls</h3>
    <p>
      You can pan, zoom, and animate the eclipse. You can change
      the speed of the animation using the <u><Icon icon="mdi:speedometer" inline/> Speed Slider</u>.
      Tuning it to the left will animate the eclipse with realistic timing.
      The <u><Icon icon="material-symbols-light:clear-night" inline/> Moon Distance Slider</u>
      controls how far away the moon is (within its orbit) from the planet. The <u><Icon icon="material-symbols-light:clear-day" inline/> Time of Day Slider</u> controls the
      position of the Sun in the sky. The <u><Icon icon="mdi:telescope" inline/> Telescope Mode</u> button lets you zoom in on the
      eclipse, where you can use the <u><Icon icon="ion:glasses" inline/> Exposure Slider</u> to adjust the amount of light the "camera"
      is capturing. To disable the music and more, check the <u><Icon icon="material-symbols:settings" inline/> Settings</u> menu.
    </p>

    <h3>
      Accuracy of the Simulation
    </h3>
    <p>
      We used <a href="https://nssdc.gsfc.nasa.gov/planetary/factsheet/" target="_blank">data from NASA</a>
      to simulate the size and distance of the planets and moons.
      And <a href="https://science.gsfc.nasa.gov/sci/bio/vincent.kofman" target="_blank">NASA's Vincent Kofman</a>,
      who specializes in simulating planetary atmospheres,
      helped us review the accuracy of the atmospheres.
      We've done our best to make this simulation as accurate as possible,
      but there are limitations. For example, the moons' shadows are simplified
      to make the simulation run faster.
    </p>
    <p>
      Atmospheres are also tricky to simulate accurately. For Earth and Mars,
      we have pictures so we can compare our simulation to reality.
      For the other planets, we have to rely on what we know about their
      atmospheres, and make educated guesses about how they scatter light.
    </p>

    <h3>Data and Credits</h3>
    <p>
      Development: Jasper Palfree <br />
      UX Design: Sarah Berman and Jasper Palfree <br />
      Interface Design: Sarah Berman <br />
      Physics Feedback: Vincent Kofman, Henry Reich <br />
      Review Team: MinuteEarth <br />
      Project Direction: Sarah Berman <br />
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
      hub for learning about our world through fun and inspiring
      web experiences.
    </p>
    <p>
      For more interactives, visit
    </p>
    <div class="centered">
      <a class="button" href="https://minutelabs.io" target="_blank">minutelabs.io</a>
    </div>
  </div>
  {:else}
  <h2 class="heading">
    <span>{$planet}</span>
    <span>{$selectedMoon}</span>
  </h2>
  <div class="content scrollbars">
    {#if $planet === 'earth'}
      <p>
        Earth: familiar, but nonetheless beautiful. The Earth boasts the best
        total eclipses in the solar system. Our moon (called Luna, in case you
        didn't know) is just the right size and distance to cover the Sun perfectly,
        at least when it's in the nearer-to-Earth part of its orbit.
        This allows us to see the Sun's corona &mdash; the outermost layer of the
        Sun's atmosphere &mdash; in its full glory without the Sun's core
        overwhelming our vision.
      </p>
    {/if}
    {#if $planet === 'mars'}
      <p>
        Mars: A dusty planet with a thin atmosphere. At the surface, the air
        pressure is about 0.6% of Earth's. The air scatters the sunlight just
        like on Earth, and it would look blue if not for the dust. The dust is
        mainly iron oxide, which on the ground this dust gives Mars its red color.
        In the air, the dust scatters the light in a way that makes the Sun look
        blue near the horizon. But if you use the time of day slider to move the
        Sun higher, you'll see the sky turn a reddish hue.
      </p>
      <p>
        Mars has two moons: Phobos and Deimos. Phobos looks small in the sky
        compared to the Sun, so it won't fully eclipse the Sun. But you can
        still see the light from the Sun dim a bit when Phobos passes in
        front of it. NASA captured photos of Phobos eclipsing the Sun from
        the surface of Mars, which makes Phobos the only other moon in our
        solar system to be photographed eclipsing the Sun from the surface of a planet.
      </p>
    {/if}
    {#if $planet === 'jupiter'}
      <p>
        Jupiter, the Giant. The largest planet in our neighborhood. The Sun is
        starting to look much smaller and farther away now. We don't have a solid
        surface to stand on here. Instead we'll hover in Jupiter's cloudy
        atmosphere at an altitude where the air pressure is about the same as
        Earth's at sea level (around 1 Bar). The Hydrogen and Helium in Jupiter's
        atmosphere scatter sunlight similarly to Earth's atmosphere, but the
        atmosphere is hazy and cloudy, so the familiar "sky blue" color is dulled.
        Oh, and those clouds you see? Those are made of ammonia crystals, not water.
      </p>
      <p>
        Jupiter has 95 recognized moons, but for simplicity, we only included
        five in the Lab. Four of these are known as the Galilean moons, and they
        all look larger in the sky than the Sun, but Callisto is the right size
        and distance to reveal some of the Sun's corona. Amalthea is an example
        of a smaller moon.
      </p>
    {/if}
    {#if $planet === 'saturn'}
      <p>
        Saturn. And before you ask, yes &mdash; the rings are visible. Move the Sun past
        the horizon to reveal the starry sky and the spectacular rings. Saturn's
        atmosphere is similar to Jupiter's, complete with Hydrogen, Helium,
        ammonia clouds, and haze. There isn't a solid place to stand, so we'll
        float in the atmosphere where it's 1 Bar of pressure; about the same as
        Earth's surface.
      </p>
      <p>
        Saturn has many moons, but the big ones are Titan and Rhea. The sizes
        of these moons relative to Saturn's sky are about the size where their
        eclipses really start to look like a shadow passing over you in the sky.
        Zoom out to see this better.
      </p>
      <p>
        You may also see some places where the simulation breaks down. Mimas,
        for example, is too close to Saturn for our simulation to work well.
        The shadow looks like a bunch of circles in the sky... and, of course,
        the real eclipse wouldn't look like that.
      </p>
    {/if}
    {#if $planet === 'uranus'}
      <p>
        Uranus. This poor planet is always the butt of a lot of jokes and puns. But it
        really is a beautiful place and, like Saturn, it has rings! There isn't a
        solid place to stand, so we'll float in the atmosphere where it's 1 Bar
        of pressure; about the same as Earth's surface. Here, the Sun is hard to
        see... if you lose track of it, double tap the screen to recenter the Sun
        and zoom in. During the day, the sky is a beautiful blue-green color,
        mainly due to the methane in Uranus' atmosphere.. The methane clouds aren't
        too shabby either.
      </p>
      <p>
        There are lots of moons to choose from. And again, like Saturn, you
        may see the simulation break down with some of the moons.
      </p>
    {/if}
    {#if $planet === 'neptune'}
      <p>
        Neptune is the farthest plane. In many pictures of Neptune, it has
        a deep blue color. But recent updates suggest that it looks very similar
        to Uranus. That makes sense, since they're both gas giants with similar
        atmospheres and methane clouds. There isn't a solid place to stand,
        so we'll float in the atmosphere where it's 1 Bar of pressure; about
        the same as Earth at sea level.
      </p>
      <p>
        Since the Sun is so far away, most of Neptune's closest moons just
        dwarf the Sun in the sky. But Nereid is small enough and far enough
        away that it's almost reminiscent of Phobos eclipsing the Sun on Mars...
        if you zoom in a lot, that is.
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