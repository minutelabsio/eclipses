import * as THREE from 'three'
import bsc5dat from '../../assets/bsc5.dat?raw'

const brightnessAdjustment = 0.8

export function starData(){
  const stars = {}
  const starData = bsc5dat.split('\n')
  const positions = new Array()
  const colors = new Array()
  const color = new THREE.Color()
  const sizes = new Array()

  starData.forEach((row) => {
    let star = {
      id: Number(row.slice(0, 4)),
      name: row.slice(4, 14).trim(),
      gLon: Number(row.slice(90, 96)),
      gLat: Number(row.slice(96, 102)),
      mag: Number(row.slice(102, 107)),
      spectralClass: row.slice(129, 130),
      v: new THREE.Vector3(),
    }

    stars[star.id] = star

    star.v = new THREE.Vector3().setFromSphericalCoords(
      1e12,
      ((90 - star.gLat) / 180) * Math.PI,
      (star.gLon / 180) * Math.PI
    )

    positions.push(star.v.x)
    positions.push(star.v.y)
    positions.push(star.v.z)

    switch (star.spectralClass) {
      case 'O':
        color.setHex(0x91b5ff)
        break
      case 'B':
        color.setHex(0xa7c3ff)
        break
      case 'A':
        color.setHex(0xd0ddff)
        break
      case 'F':
        color.setHex(0xf1f1fd)
        break
      case 'G':
        color.setHex(0xfdefe7)
        break
      case 'K':
        color.setHex(0xffddbb)
        break
      case 'M':
        color.setHex(0xffb466)
        break
      case 'L':
        color.setHex(0xff820e)
        break
      case 'T':
        color.setHex(0xff3a00)
        break
      default:
        color.setHex(0xffffff)
    }

    const s = (star.mag * 26) / 255 + 0.18
    sizes.push(s)

    colors.push(color.r, color.g, color.b, s * brightnessAdjustment)
  })

  return {
    positions,
    colors,
    sizes,
  }
}