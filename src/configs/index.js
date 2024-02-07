import earthConfig from './earth'
import marsConfig from './mars'
import jupiterConfig from './jupiter'
import saturnConfig from './saturn'
import uranusConfig from './uranus'
import neptuneConfig from './neptune'

export const earth = Object.assign({ planet: 'earth' }, earthConfig)
export const mars = Object.assign({ planet: 'mars' }, marsConfig)
export const jupiter = Object.assign({ planet: 'jupiter' }, jupiterConfig)
export const saturn = Object.assign({ planet: 'saturn' }, saturnConfig)
export const uranus = Object.assign({ planet: 'uranus' }, uranusConfig)
export const neptune = Object.assign({ planet: 'neptune' }, neptuneConfig)
