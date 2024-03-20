const sq = x => x * x

// area of intersection of two circles
export function twoCircleIntersection(r1, r2, d){
  let area
  if (d <= Math.abs(r1 - r2)) {
    // one circle is completely inside the other
    area = Math.PI * sq(Math.min(r1, r2))
  } else if (d >= r1 + r2) {
    // the circles do not overlap
    area = 0
  } else {
    // the circles partially overlap
    const a1 = sq(r1) * Math.acos((sq(d) + sq(r1) - sq(r2)) / (2 * d * r1))
    const a2 = sq(r2) * Math.acos((sq(d) + sq(r2) - sq(r1)) / (2 * d * r2))
    const a3 = 0.5 * Math.sqrt((-d + r1 + r2) * (d + r1 - r2) * (d - r1 + r2) * (d + r1 + r2))
    area = a1 + a2 - a3
  }
  return area
}

// angular diameter of the sun and moon
export function solarOcclusion(dSun, pSun, dMoon, pMoon){
  const rSun = 0.5 * dSun
  const rMoon = 0.5 * dMoon
  const sSun = pSun.clone().normalize()
  const sMoon = pMoon.clone().normalize()
  const d = sSun.distanceTo(sMoon)
  const a = twoCircleIntersection(rSun, rMoon, d)
  const sun = Math.PI * sq(rSun)
  return a / sun
}

export function solarVisibility(dSun, pSun, dMoon, pMoon){
  return 1 - solarOcclusion(dSun, pSun, dMoon, pMoon)
}