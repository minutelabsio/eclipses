varying vec3 vWorldPosition;
uniform float opacity;
uniform vec3 moonPosition;
uniform float moonRadius;
uniform float altitude;
uniform float sunIntensity;
uniform vec3 sunPosition;
uniform float sunRadius;
uniform float planetRadius;
uniform float atmosphereThickness;
uniform vec3 rayleighCoefficients;
uniform float rayleighScaleHeight;
uniform float mieCoefficient;
uniform float mieScaleHeight;
uniform float mieDirectional;

#pragma glslify: atmosphere = require(glsl-atmosphere)

void main() {

  vec3 moonDir = normalize(moonPosition);
  vec3 rayDir = normalize(vWorldPosition);
  vec3 sunDir = normalize(sunPosition);

  // apparent radius of sun
  float sunAngle = acos(dot(sunDir, rayDir));
  float sunAngularRadius = asin(sunRadius / length(sunPosition));

  // apparent radius of the moon
  float moonAngle = acos(dot(moonDir, rayDir));
  float moonAngularRadius = asin(moonRadius / length(moonPosition));
  float intensity = sunIntensity;

  // moon eclipse
  if(moonAngle < moonAngularRadius) {
    // intensity *= smoothstep(0.0, 1.0, 0.2 * sunAngle / sunAngularRadius);
    // debug
    // gl_FragColor = vec4(0.0, 0.0, 1.0, 1.0);
    // return;
  }

  // debug
  // if (moonAngle < moonAngularRadius) {
  //   gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
  //   return;
  // }

  // // debug
  // if(sunAngle < sunAngularRadius) {
  //   gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
  //   return;
  // }

  vec3 color = atmosphere(
    rayDir,           // normalized ray direction
    vec3(0, planetRadius + altitude, 0),  // ray origin
    sunDir,                        // direction of the sun
    intensity,                           // intensity of the sun
    planetRadius,                         // radius of the planet in meters
    planetRadius + atmosphereThickness,                         // radius of the atmosphere in meters
    rayleighCoefficients, // Rayleigh scattering coefficient
    mieCoefficient,                          // Mie scattering coefficient
    rayleighScaleHeight,                            // Rayleigh scale height
    mieScaleHeight,                          // Mie scale height
    mieDirectional                         // Mie preferred scattering direction
  );

  // Apply exposure.
  color = 1.0 - exp(-1.0 * color);

  gl_FragColor = vec4(color, opacity);
}