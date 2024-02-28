
export const createDragger = (startPos = [0, 0], opts = {}) => {
  const options = Object.assign(
    {
      friction: 0.02
      , threshold: 1e-3
      , minFlick: 0.1
      , maxFlick: 8
    },
    opts
  )
  let r0 = false
  const pos = startPos
  let oldPos
  let dx, dy
  let ds
  let time = 0
  let lastDragTime
  let lastPos = []
  let dt = 0
  const now = window.performance.now.bind(window.performance)

  function start(r) {
    if (r0){
      return
    }
    r0 = r
    oldPos = pos.slice(0)
  }

  function drag(r, zoom = 1) {
    if (!r0) {
      return
    }
    lastPos = pos.slice(0)
    pos[0] = oldPos[0] + (r[0] - r0[0]) / zoom
    pos[1] = oldPos[1] + (r[1] - r0[1]) / zoom
    const t = now()
    dt = Math.max(20, t - lastDragTime)
    lastDragTime = t
  }

  function stop(r, zoom = 1) {
    if (!r0) {
      return
    }
    r0 = false
    if ((now() - lastDragTime) > 50) {
      dx = dy = 0
      return
    }
    dx = (pos[0] - lastPos[0])
    dy = (pos[1] - lastPos[1])
    ds = Math.sqrt(dx * dx + dy * dy)
    if (ds < options.minFlick / zoom) {
      ds = 0
      dx = 0
      dy = 0
    } else if (ds > options.maxFlick / zoom) {
      const max = options.maxFlick / zoom / ds
      dx *= max
      dy *= max
      ds = options.maxFlick
    }
    dx *= 4 / dt
    dy *= 4 / dt
    ds *= 4 / dt
  }

  function momentum(t) {
    if (!dx && !dy) {
      return
    }
    const dt = t - time
    pos[0] += dx * dt
    pos[1] += dy * dt
    if (dx) {
      dx -= options.friction * dx
    }
    if (dy) {
      dy -= options.friction * dy
    }
    if (
      (dx * dx + dy * dy) / (ds * ds) <
      options.threshold * options.threshold
    ) {
      dx = dy = 0
    }
  }

  function update() {
    const t = now()
    if (!r0) {
      momentum(t)
    }
    time = t
    return pos
  }

  return {
    start
    , drag
    , stop
    , set: ([x, y]) => {
      pos[0] = x
      pos[1] = y
    }
    , update
  }
}