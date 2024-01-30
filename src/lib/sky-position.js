import { Vector3 } from 'three'

export const skyPosition = (distance, elevation, declination, into = []) => {
  const p = [
    distance * Math.cos(elevation) * Math.sin(declination),
    distance * Math.sin(elevation),
    distance * Math.cos(elevation) * Math.cos(declination)
  ]
  if (into instanceof Vector3) {
    into.set(...p)
    return into
  }
  return p
}