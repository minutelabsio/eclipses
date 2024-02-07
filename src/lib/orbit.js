const pfx = (str, prefix) => {
  if (prefix) {
    return `${prefix}${str[0].toUpperCase()}${str.slice(1)}`
  }
  return str
}

export const apoapsis = (a, e) => a * (1 + e)
export const periapsis = (a, e) => a * (1 - e)
export const bothApsis = (a, e, prefix = '') => ({
  [pfx('apoapsis', prefix)]: apoapsis(a, e),
  [pfx('periapsis', prefix)]: periapsis(a, e)
})