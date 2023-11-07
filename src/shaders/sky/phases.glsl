#define PI 3.1415926535897932384626433832795

const float THREE_OVER_16_PI = 3.0 / (16.0 * PI);
const float THREE_OVER_8_PI = 3.0 / (8.0 * PI);

vec2 phases(
  vec3 rayOrigin,
  vec3 rayDir,
  vec3 sunPosition,
  float g
) {
  vec3 sSun = normalize(sunPosition - rayOrigin);
  // phases
  float mu = dot(rayDir, sSun);
  float mumu = mu * mu;
  float gg = g * g;
  float rayleighP = THREE_OVER_16_PI + THREE_OVER_16_PI * mumu;
  float mieP = THREE_OVER_8_PI * ((1.0 - gg) * (mumu + 1.0)) / (pow(1.0 + gg - 2.0 * mu * g, 1.5) * (2.0 + gg));
  return vec2(rayleighP, mieP);
}

#pragma glslify: export(phases)