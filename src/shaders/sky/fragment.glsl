varying vec3 vWorldPosition;
uniform float opacity;
uniform float altitude;
uniform float sunIntensity;
uniform vec3 sunDir;
uniform float planetRadius;
uniform float atmosphereThickness;
uniform vec3 rayleighCoefficients;
uniform float rayleighScaleHeight;
uniform float mieCoefficient;
uniform float mieScaleHeight;
uniform float mieDirectional;

#pragma glslify: atmosphere = require(glsl-atmosphere)

void main() {
  vec3 color = atmosphere(
    normalize(vWorldPosition),           // normalized ray direction
    vec3(0, planetRadius + altitude, 0),  // ray origin
    sunDir,                        // direction of the sun
    sunIntensity,                           // intensity of the sun
    planetRadius,                         // radius of the planet in meters
    planetRadius + atmosphereThickness,                         // radius of the atmosphere in meters
    rayleighCoefficients, // Rayleigh scattering coefficient
    mieCoefficient,                          // Mie scattering coefficient
    rayleighScaleHeight,                            // Rayleigh scale height
    mieScaleHeight,                          // Mie scale height
    mieDirectional                           // Mie preferred scattering direction
  );

  // Apply exposure.
  color = 1.0 - exp(-1.0 * color);

  gl_FragColor = vec4(color, opacity);
}