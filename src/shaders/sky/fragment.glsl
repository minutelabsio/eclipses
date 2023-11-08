varying vec3 vWorldPosition;
varying vec2 vUv;

uniform sampler2D opticalDepthMap;
uniform float opticalDepthMapSize;
uniform float altitude;
uniform float sunRadius;
uniform float moonRadius;

uniform float opacity;
uniform vec3 moonPosition;
uniform float sunIntensity;
uniform vec3 sunPosition;
uniform float planetRadius;
uniform float atmosphereThickness;
uniform vec3 rayleighCoefficients;
uniform float rayleighScaleHeight;
uniform float mieCoefficient;
uniform float mieScaleHeight;
uniform float mieDirectional;
uniform float exposure;
uniform int iSteps;
uniform int jSteps;

#define PI 3.1415926535897932384626433832795

const float THREE_OVER_16_PI = 3.0 / (16.0 * PI);
const float THREE_OVER_8_PI = 3.0 / (8.0 * PI);
const float MIN_STEP_SIZE = 1e4;

vec2 opticalDensity(float z, vec2 scaleHeights, float planetRadius) {
  float h = max(0.0, z - planetRadius);
  return clamp(exp(-h / scaleHeights), 0., 1.);
}

// optical depth from start to end in the atmosphere
vec2 opticalDepths(vec3 start, vec3 end, vec2 scaleHeights, float planetRadius, int steps) {
  vec2 od = vec2(0.0);
  float fsteps = float(steps);
  float d = length(end - start);
  float ds = max(MIN_STEP_SIZE, d / fsteps);
  fsteps = ceil(length(end - start) / ds);
  int isteps = int(fsteps);
  ds = d / fsteps;
  for(int i = 0; i < isteps; i++) {
    float t = (float(i) + 0.5) / fsteps;
    vec3 p = mix(start, end, t);
    od += opticalDensity(length(p), scaleHeights, planetRadius) * ds;
  }
  return od;
}

vec2 getOpticalDepths(vec3 start, vec3 s, float planetRadius, float atmosphereRadius) {
  float h = max(0.0, length(start) - planetRadius);
  // vec3 s = normalize(end - start);
  start = normalize(start);
  float angle = acos(dot(start, s));
  float ah = atmosphereRadius - planetRadius;
  float halfStep = 0.5 / opticalDepthMapSize;
  vec2 texCoord = vec2(angle / PI + halfStep, h / ah + halfStep);
  vec2 data = texture2D(opticalDepthMap, texCoord).rg;
  return data;
}

vec2 raySphereIntersection(vec3 origin, vec3 ray, float radius) {
  ray = normalize(ray);
  // ray-sphere intersection that assumes
  // the sphere is centered at the origin.
  // float a = dot(ray, ray);
  // float b = 2.0 * dot(ray, origin);
  // float c = dot(origin, origin) - (radius * radius);
  // return solveQuadratic(a, b, c);
  float b = dot(ray, origin);
  float c = dot(origin, origin) - (radius * radius);
  float d = b * b - c;
  if(d < 0.0) {
    return vec2(1e5, -1e5);
  }
  float sqrtd = sqrt(d);
  float x0 = -b - sqrtd;
  float x1 = -b + sqrtd;
  if(x0 > x1) {
    return vec2(x1, x0);
  } else {
    return vec2(x0, x1);
  }
}

float twoCircleIntersection(float r1, float r2, float d) {
  if(d > r1 + r2) {
    return 0.0;
  } else if(d <= abs(r1 - r2)) {
    float r = min(r1, r2);
    return PI * r * r;
  }
  float d2 = d * d;
  float r12 = r1 * r1;
  float r22 = r2 * r2;
  float r12mr22 = r12 - r22;
  float twod = 2.0 * d;
  float twod2 = 2.0 * d2;
  vec2 r1r2 = vec2(r1, r2);
  float area = dot(r1r2 * r1r2, acos(vec2(d2 + r12mr22, d2 - r12mr22) / (twod * r1r2))) - 0.5 * sqrt(dot(vec4(-r12mr22, twod2, twod2, -d2), vec4(r12mr22, r12, r22, d2)));
  return area;
}

// amount of the sun that is unobstructed by the moon
float umbra(vec3 ri, float thetaSun, vec3 pSun, float thetaMoon, vec3 pMoon) {
  vec3 sSun = normalize(pSun - ri);
  vec3 sMoon = normalize(pMoon - ri);
  float d = length(sSun - sMoon);
  float rSun = tan(thetaSun);
  float rMoon = tan(thetaMoon);
  float area = twoCircleIntersection(rSun, rMoon, d);
  float totalArea = PI * rSun * rSun;
  return max(1e-6, 1.0 - area / totalArea);
}

float smoothcircle(vec3 ray, float angularRadius, vec3 centerDir, float boundary){
  float angle = acos(dot(centerDir, ray));
  float b = boundary * angularRadius;
  return 1.0 - smoothstep(angularRadius - b, angularRadius + b, angle);
}

vec3 scattering(
  vec3 rayOrigin,
  vec3 rayDir,
  // rayleigh xyz, mie w
  vec4 scatteringCoefficients,
  vec2 scaleHeights,
  // mie directional g
  float g,
  float planetRadius,
  // sun intensity
  float I0,
  // sun position
  vec3 sunPosition,
  float sunAngularRadius,
  // moon position
  vec3 moonPosition,
  float moonAngularRadius,
  // really just a cuttoff for the atmosphere
  float atmosphereRadius,
  ivec2 steps
){
  // determine intersections with the planet, atmosphere, etc
  vec2 intPlanet = raySphereIntersection(rayOrigin, rayDir, planetRadius);
  bool planet_intersected = (intPlanet.x <= intPlanet.y && intPlanet.x > 0.0);

  // Ray starts inside the planet -> return 0
  if (intPlanet.x < 0.0 && intPlanet.y > 0.0) {
    return vec3(0.0, 0.0, 0.0);
  }

  vec3 sSun = normalize(sunPosition - rayOrigin);

  // Color of the solar disk (that isn't blocked by the moon)
  float sunDisk = 0.0;
  // we can't see the sun if the ray intersects the planet
  if(!planet_intersected) {
    sunDisk = smoothcircle(rayDir, sunAngularRadius, sSun, 0.01);
    // the smoothstep ends up looking brighter near the second edge
    // so for the moon we need to fudge it to get the correct relative size
    float moonDisk = smoothcircle(rayDir, moonAngularRadius * 1.02, normalize(moonPosition - rayOrigin), 0.01);
    sunDisk = mix(sunDisk, 0.0, moonDisk);
    // float bloom = 2. * smoothcircle(rayDir, 2.0 * sunAngularRadius, sSun, 0.5) / I0;
    // sunDisk += bloom;
  }

  vec2 path = raySphereIntersection(rayOrigin, rayDir, atmosphereRadius);
  // Ray does not intersect the atmosphere (on the way forward) at all;
  // exit early.
  if (path.x > path.y || path.y <= 0.0) {
    return vec3(I0 * sunDisk);
  }

  // always start atmosphere ray at viewpoint if we start inside atmosphere
  path.x = max(path.x, 0.0);

  // if the planet is intersected, set the end of the ray to the planet
  // surface.
  path.y = planet_intersected ? intPlanet.x : path.y;

  vec3 rayleighT = vec3(0.0);
  vec3 mieT = vec3(0.0);
  // begin calculating transmittance via optical depth accumulation
  vec2 primaryDepth = vec2(0.0);

  vec3 start = rayOrigin + rayDir * path.x;
  vec3 end = rayOrigin + rayDir * path.y;

  float fsteps = float(steps.x);
  float d = (path.y - path.x);
  // float ds = max(MIN_STEP_SIZE, d / fsteps);
  // // adjust the number of steps to compensate for min step size
  // fsteps = ceil(d / ds);
  // steps.x = int(fsteps);
  float ds = d / fsteps;

  for (int i = 0; i < steps.x; i++){
    float t = (float(i) + 0.5) / fsteps;
    vec3 pos = mix(start, end, t);
    vec2 odStep = opticalDensity(length(pos), scaleHeights, planetRadius) * ds;
    primaryDepth += odStep;

    vec2 intPlanet2 = raySphereIntersection(pos, sSun, planetRadius);
    float earthShadow = 1.0;
    // if it intersects the planet, we're in shadow
    if (intPlanet2.x < intPlanet2.y && intPlanet2.y > 0.0) {
      // not sure if this is the best thing to do
      earthShadow = 1.0 - smoothstep(-0.2, 0.2, asin(0.5 * max(0.0, intPlanet2.y - intPlanet2.x) / planetRadius));
    }
    vec2 intAtmosphere2 = raySphereIntersection(pos, sSun, atmosphereRadius);
    vec3 exit = pos + intAtmosphere2.y * sSun;
    // vec2 secondaryDepth = opticalDepths(pos, exit, scaleHeights, planetRadius, steps.y);
    vec2 secondaryDepth = getOpticalDepths(pos, normalize(exit - pos), planetRadius, atmosphereRadius);
    float g = umbra(
      pos,
      sunAngularRadius,
      sunPosition,
      moonAngularRadius,
      moonPosition
    );
    vec2 depth = primaryDepth + secondaryDepth;
    vec4 alpha = vec4(vec3(depth.x), depth.y) * scatteringCoefficients;
    vec3 transmittance = earthShadow * g * exp(- alpha.xyz - alpha.w);

    rayleighT += transmittance * odStep.x;
    mieT += transmittance * odStep.y;
  }

  // phases
  float mu = dot(rayDir, sSun);
  float mumu = mu * mu;
  float gg = g * g;
  float rayleighP = THREE_OVER_16_PI + THREE_OVER_16_PI * mumu;
  float mieP = THREE_OVER_8_PI * ((1.0 - gg) * (mumu + 1.0)) / (pow(1.0 + gg - 2.0 * mu * g, 1.5) * (2.0 + gg));

  vec3 scatter = rayleighT * rayleighP * scatteringCoefficients.xyz + mieT * mieP * scatteringCoefficients.w;
  return I0 * scatter + vec3(I0 * sunDisk);
}

void main() {
  vec3 RayOrigin = vec3(0, planetRadius + altitude + 1.0, 0);
  vec3 RayDir = normalize(vWorldPosition);

  // debug optical depth
  // vec2 od = opticalDepths(
  //   normalize(RayOrigin),
  //   normalize(RayDir + RayOrigin),
  //   vec2(rayleighScaleHeight),
  //   planetRadius, ivec2(iSteps, jSteps)
  // );
  // vec2 od = getOpticalDepths(
  //   RayOrigin,
  //   RayDir,
  //   planetRadius,
  //   planetRadius + atmosphereThickness
  // );

  // gl_FragColor = vec4(1. - exp(-0.02* od.x), 1. - exp(-0.02 * od.y), 0.0, 1.0);
  // gl_FragColor = vec4(od.x, od.y, 0.0, 1.0);
  // return;
  // angular radii of sun and moon change very little
  float SunAngularRadius = asin(sunRadius / length(sunPosition - RayOrigin));
  float MoonAngularRadius = asin(moonRadius / length(moonPosition - RayOrigin));

  vec3 color = scattering(
    RayOrigin,
    RayDir,
    vec4(rayleighCoefficients, mieCoefficient),
    vec2(rayleighScaleHeight, mieScaleHeight),
    mieDirectional,
    planetRadius,
    sunIntensity,
    sunPosition,
    SunAngularRadius,
    moonPosition,
    MoonAngularRadius,
    planetRadius + atmosphereThickness,
    ivec2(iSteps, jSteps)
  );

  // vec2 intPlanet = raySphereIntersection(RayOrigin, RayDir, planetRadius);
  // bool planet_intersected = (intPlanet.x <= intPlanet.y && intPlanet.x > 0.0);

  // if (planet_intersected){
  //   gl_FragColor = vec4(0.0, 0.0, 0.0, opacity);
  //   return;
  // }

  // vec2 p = phases(
  //   RayOrigin,
  //   RayDir,
  //   sunPosition,
  //   mieDirectional
  // );

  // vec3 scatter = vRayleighT * p[0] + vMieT * p[1];
  // vec3 color = sunIntensity * scatter;

  // apply gamma correction
  // color = 0.4 * pow(color, vec3(1.0 / 1.2));
  // Apply exposure.
  color = 1.0 - exp(-exposure * color);

  gl_FragColor = vec4(color, opacity);
}