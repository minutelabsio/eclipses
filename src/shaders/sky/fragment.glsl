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
uniform float exposure;

#pragma glslify: atmosphere = require(./atmosphere.glsl)

void main() {
  vec3 origin = vec3(0, planetRadius + altitude, 0);
  // vec3 moonDir = normalize(moonPosition);
  vec3 rayDir = normalize(vWorldPosition);
  // vec3 sunDir = normalize(sunPosition);

  // apparent radius of sun
  // float sunAngle = acos(dot(sunDir, rayDir));
  // float sunAngularRadius = asin(sunRadius / length(sunPosition));

  // // apparent radius of the moon
  // float moonAngle = acos(dot(moonDir, rayDir));
  // float moonAngularRadius = asin(moonRadius / length(moonPosition));
  float intensity = sunIntensity;

  // // TODO: All of these angular diameters need to take into account the earth radius and altitude
  // // apparent size of moon umbra
  // float moonUmbraRadius = asin(moonRadius / (length(moonPosition) - atmosphereThickness));
  // vec3 moonUmbraDir = normalize(moonPosition - sunPosition);
  // float a = acos(-dot(moonUmbraDir, sunDir));
  // vec3 moonUmbraPos = tan(a) * length(sunPosition) * moonUmbraDir;
  // float umbraAngle = acos(dot(moonUmbraDir, rayDir));

  // // moon eclipse
  // if(moonAngle < moonAngularRadius && sunAngle < sunAngularRadius) {
  //   intensity *= smoothstep(0.0, 1.0, 0.01 * sunAngle / sunAngularRadius);
  //   // debug
  //   // gl_FragColor = vec4(0.0, 0.0, 1.0, 1.0);
  //   // return;
  // } else if (moonAngle < moonAngularRadius){
  //   intensity *= 0.2;
  // }


  // // debug
  // if (moonAngle < moonAngularRadius) {
  //   gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
  //   return;
  // }

  // // debug
  // if(sunAngle < sunAngularRadius) {
  //   gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
  //   return;
  // }

  vec4 pixel = atmosphere(
    rayDir,           // normalized ray direction
    origin,  // ray origin
    sunPosition,                        // direction of the sun
    sunRadius,
    moonPosition,
    moonRadius,
    intensity,                           // intensity of the sun
    planetRadius,                         // radius of the planet in meters
    planetRadius + atmosphereThickness,                         // radius of the atmosphere in meters
    rayleighCoefficients, // Rayleigh scattering coefficient
    mieCoefficient,                          // Mie scattering coefficient
    rayleighScaleHeight,                            // Rayleigh scale height
    mieScaleHeight,                          // Mie scale height
    mieDirectional                         // Mie preferred scattering direction
  );

  vec3 color = pixel.xyz;
  // apply gamma correction
  // color = pow(color, vec3(1.0 / 2.2));
  // Apply exposure.
  color = 1.0 - exp(-exposure * color);

  gl_FragColor = vec4(color, opacity * pixel.a);
}