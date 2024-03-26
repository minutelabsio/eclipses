<script>
import { planet, selectedMoon } from '../../store/environment'
</script>

<section class="about">
  <h2 class="heading">
    <span>{$planet}</span>
    <span>{$selectedMoon}</span>
  </h2>
  <p>Lorem ipsum dolor sit amet consectetur. Orci feugiat tortor suspendisse elementum. Pharetra proin scelerisque turpis volutpat egestas bibendum tellus eget posuere. Enim consectetur nec mauris nunc volutpat. Ut placerat magna nulla eget. Viverra dictum sapien quam quam dui vitae mi ac. Scelerisque suscipit sed sed neque quam morbi nisl viverra. Nisl elit lacus at eleifend tincidunt. Convallis mauris in amet eu. Mattis.</p>
</section>

<style lang="sass">
  .about
    color: white
    font-size: 14px
    font-weight: 400
    height: 100%
    padding: 1.5rem 0.5rem
    overflow-y: auto
  .heading
    display: flex
    justify-content: space-between
    font-size: 10px
    font-weight: 400
    margin: 0
    text-transform: uppercase
</style>