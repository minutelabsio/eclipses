varying vec3 vWorldPosition;
varying vec2 vUv;
varying vec3 vCameraDirection;
varying vec3 rayOrigin;
varying float SunAngularRadius;
varying float MoonAngularRadius;

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

const float ONE_OVER_E = exp(-1.0);
const float THREE_OVER_16_PI = 3.0 / (16.0 * PI);
const float THREE_OVER_8_PI = 3.0 / (8.0 * PI);
const float MIN_STEP_SIZE = 1e4;

vec2 opticalDensity(float z, vec2 scaleHeights, float planetRadius) {
  float h = max(0.0, z - planetRadius);
  return clamp(exp(-h / scaleHeights), 0., 1.);
}

float shellDensity(int index, int steps){
  if (index == steps){
    return 0.0;
  } else if (index == 0){
    return 1.0;
  } else {
    return 1. - float(index) / float(steps);
  }
}

// spherical shells starting at Re -> Re + atmosphereThickness
float shellRadius(int index, int steps, float H, float atmosphereThickness, float planetRadius){
  if (index == steps){
    return atmosphereThickness + planetRadius;
  } else if (index == 0){
    return planetRadius;
  } else {
    return planetRadius - H * log(1. - float(index) / float(steps));
  }
}

// optical depth from start to end in the atmosphere
vec2 opticalDepths(vec3 start, vec3 end, vec2 scaleHeights, float planetRadius, int steps) {
  vec2 od = vec2(0.0);
  float fsteps = float(steps);
  float d = length(end - start);
  float ds = d / fsteps;
  float invFsteps = 1.0 / fsteps;
  float halfstep = 0.5 * invFsteps;
  vec3 p;
  for(float t = halfstep; t < 1.0; t += invFsteps) {
    p = mix(start, end, t);
    od += opticalDensity(length(p), scaleHeights, planetRadius) * ds;
  }
  return od;
}

vec2 getOpticalDepths(vec3 start, vec3 s, vec2 scaleHeights, float planetRadius, float atmosphereRadius) {
  // float ah = atmosphereRadius - planetRadius;
  float h = max(0.0, length(start) - planetRadius);
  float v = (1. - exp(-h / scaleHeights.x));
  // vec3 s = normalize(end - start);
  start = normalize(start);
  float angle = acos(dot(start, s));
  // Math.PI * (4 * (t - 0.5) ^ 3 + 0.5)
  float u = angle / PI;
  // float c = 0.5 - abs(0.5 - angle / PI);
  // float u = asin(1. - cos(PI * c)) / PI;
  float halfStep = 0.5 / opticalDepthMapSize;
  vec2 texCoord = vec2(u + halfStep, v + halfStep);
  vec2 data = texture2D(opticalDepthMap, texCoord).rg;
  return data;
}

vec2 raySphereIntersection(vec3 origin, vec3 ray, float radius) {
  // ray = normalize(ray);
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
    return vec2(1e-5, -1e-5);
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

bool intersects1(vec2 intersections){
  return intersections.x <= intersections.y && intersections.x > 0.0;
}

bool intersects2(vec2 intersections) {
  return intersections.x <= intersections.y && intersections.y > 0.0;
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
float umbra(vec3 ri, float rSun, vec3 pSun, float rMoon, vec3 pMoon) {
  vec3 sSun = normalize(pSun - ri);
  vec3 sMoon = normalize(pMoon - ri);
  float d = length(sSun - sMoon);
  float area = twoCircleIntersection(rSun, rMoon, d);
  float totalArea = PI * rSun * rSun;
  return max(1e-6, 1.0 - area / totalArea);
}

float smoothcircle(vec3 ray, float angularRadius, vec3 centerDir, float boundary){
  float angle = acos(dot(centerDir, ray));
  float b = boundary * angularRadius;
  return 1.0 - smoothstep(angularRadius - b, angularRadius + b, angle);
}

float closestApproachDepth(vec3 start, vec3 ray, float planetRadius) {
  float dist = dot(ray, start);
  if (dist >= 0.0){
    return 0.0;
  }
  float depth = planetRadius - sqrt(dot(start, start) - dist * dist);
  return max(0.0, depth);
}

float clampMix(float x, float y, float a) {
  return mix(x, y, clamp(a, 0.0, 1.0));
}

float expScale(float x){
  return exp(x) * ONE_OVER_E - 1.0;
}

vec2 getPhases(vec3 rayDir, vec3 sSun, float g){
  // phases
  float mu = dot(rayDir, sSun);
  float mumu = mu * mu;
  float gg = g * g;
  float rayleighP = THREE_OVER_16_PI + THREE_OVER_16_PI * mumu;
  float mieP = THREE_OVER_8_PI * ((1.0 - gg) * (mumu + 1.0)) / (pow(1.0 + gg - 2.0 * mu * g, 1.5) * (2.0 + gg));
  return vec2(rayleighP, mieP);
}
float rand(vec2 n) {
  return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p) {
  vec2 ip = floor(p);
  vec2 u = fract(p);
  u = u * u * (3.0 - 2.0 * u);

  float res = mix(mix(rand(ip), rand(ip + vec2(1.0, 0.0)), u.x), mix(rand(ip + vec2(0.0, 1.0)), rand(ip + vec2(1.0, 1.0)), u.x), u.y);
  return res * res;
}

#pragma glslify: snoise3 = require(glsl-noise/simplex/3d)
#pragma glslify: cnoise3 = require(glsl-noise/classic/3d)
#pragma glslify: cnoise2 = require(glsl-noise/classic/2d)


vec3 sunMoon(vec3 rayDir, vec3 sSun, float sunAngularRadius, vec3 sMoon, float moonAngularRadius, float I0){
  float mu = dot(rayDir, sSun);
  if (mu < 0.999){
    return vec3(0.0);
  }
  mu = max(mu, 0.99);
  // Color of the solar disk (that isn't blocked by the moon)
  float sunDisk = 0.0;
  sunDisk = smoothcircle(rayDir, sunAngularRadius, sSun, 0.01);

  float g = 0.9997; //clampMix(0.99993, 0.999, (acos(dot(sSun, sMoon)) - 0.001) / 0.02);
  float gg = g * g;
  float mumu = mu * mu;
  // sunDisk = (0.001) * THREE_OVER_8_PI * ((1.0 - gg) * (mumu + 1.0)) / (pow(1.0 + gg - 2.0 * mu * g, 1.5) * (2.0 + gg));

  float moonDisk = smoothcircle(rayDir, moonAngularRadius * 1.0, sMoon, 0.01);

  sunDisk += I0 * 0.000003 * (1. - gg) * (mumu + 1.0) / pow(1. + gg - 2. * mu * g, 1.5);
  sunDisk = mumu*(1. - 0.3*cnoise3(vec3(normalize(rayDir-sSun).xy * 6., 3.*snoise3(20.*vCameraDirection)))) * mix(sunDisk, 0.0, moonDisk);
  // sunDisk *= smoothstep(0.9997 * (1. - 0.0008 * cnoise3(6.*normalize(rayDir - sSun))), 1.0, mu);
  sunDisk = mix(0.0, sunDisk, mumu/5.);

  return vec3(clamp(sunDisk, 0.0, I0));
}

float screenDist(vec3 a, vec3 b){
  return 1. / dot(a, b);
}

// get the 2d point on the screen that a ray intersects
vec2 squash(vec3 p, vec3 n){
  vec3 yaxis = vec3(0.0, 1.0, 0.0);
  vec3 up = normalize(yaxis - dot(yaxis, n) * n);
  vec3 right = normalize(cross(up, n));
  return vec2(dot(p, right), dot(p, up));
}

vec4 circleCircleChord(float r1, vec2 c2, float r2){
  float d2 = dot(c2, c2);
  float r1r2 = r1 + r2;
  if (d2 > r1r2 * r1r2){
    return vec4(1e18);
  }
  float r12 = r1 * r1;
  float r22 = r2 * r2;
  float phi = (d2 - r22 + r12);
  float d = sqrt(d2);
  float x = phi / (2. * d);
  float disc = 4. * d2 * r12 - phi * phi;
  if (disc < 0.0){
    return vec4(1e18);
  }
  float y = sqrt(disc) / (2. * d);
  vec2 b = normalize(c2);
  vec2 mid = b * x;
  vec2 perp = vec2(-b.y, b.x) * y;
  return vec4(mid + perp, mid - perp);
}

vec2 nearestEdgePoint(vec2 p, vec2 c, float r){
  vec2 d = p - c;
  float l = length(d);
  return c + d * (r / l);
}

// distance of point from edge of a clipped region of a circle, clipped by another circle
float circleEdge(vec2 p, float r1, vec2 c2, float r2){
  // check both edges
  vec2 e1 = nearestEdgePoint(p, vec2(0.0), r1);
  vec2 e2 = nearestEdgePoint(p, c2, r2);

  float e1d = distance(e1, p);
  float e2d = distance(e2, p);

  // if edge 1 is outside the second circle, and closer return distance to edge 1
  if (length(e1 - c2) > r2 && e1d < e2d){
    return length(p) - r1;
  }

  float de2 = r2 - length(p - c2);
  // if edge 2 is inside first circle, and closer return distance to edge 2
  if(length(e2) < r1 && e2d < e1d) {
    return de2;
  }

  // otherwise we return the distance to the nearest chord vertex
  vec4 chord = circleCircleChord(r1, c2, r2);
  float d1 = distance(p, chord.xy);
  float d2 = distance(p, chord.zw);
  return min(d1, d2);
}

const float bloomFactor = 8e-6;
float sunMoonIntensity(vec3 rayDir, vec3 sSun, float sunAngularRadius, vec3 sMoon, float moonAngularRadius, float I0){
  float mu = dot(rayDir, sSun);
  if(mu < 0.9995) {
    return 0.0;
  }
  // screen space of ray and moon, sun is at origin
  vec2 moonxy = squash(sMoon, sSun);
  vec2 rayxy = squash(rayDir, sSun);

  float distFromSunEdge = circleEdge(rayxy, sunAngularRadius, moonxy, moonAngularRadius);
  distFromSunEdge = max(0.0, distFromSunEdge);

  // TODO: should also account for thickness of segment for more bloom

  float bloom = min(1.0, bloomFactor / sqrt(distFromSunEdge));
  return step(0.001, bloom) * bloom * I0;
}

vec4 scattering(
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
  // float rayHeight = length(rayOrigin);
  // // Ray starts inside the planet -> return 0
  // if (rayHeight < planetRadius) {
  //   return vec4(0.0);
  // }

  float rApparentSun = tan(SunAngularRadius);
  float rApparentMoon = tan(moonAngularRadius);

  float sunDisk = sunMoonIntensity(
    rayDir,
    normalize(sunPosition - rayOrigin),
    SunAngularRadius,
    normalize(moonPosition - rayOrigin),
    MoonAngularRadius,
    sunIntensity
  );

  // vec2 inter = raySphereIntersection(rayOrigin, rayDir, atmosphereRadius);
  // // Ray does not intersect the atmosphere (on the way forward) at all;
  // if(!intersects2(inter)) {
  //   return vec4(0.0);
  // }

  vec2 path = raySphereIntersection(rayOrigin, rayDir, atmosphereRadius);
  // Ray does not intersect the atmosphere (on the way forward) at all;
  // exit early.
  if (!intersects2(path)) {
    return vec4(vec3(sunDisk), 0.0);
  }

  // always start atmosphere ray at viewpoint if we start inside atmosphere
  path.x = max(path.x, 0.0);

  // if the planet is intersected, set the end of the ray to the planet
  // surface.
  // determine intersections with the planet, atmosphere, etc
  vec2 intPlanet = raySphereIntersection(rayOrigin, rayDir, planetRadius);
  bool planet_intersected = intersects1(intPlanet);
  path.y = planet_intersected ? intPlanet.x : path.y;

  sunDisk = planet_intersected ? 0.0 : sunDisk;

  vec3 start = rayOrigin + rayDir * path.x;
  vec3 end = rayOrigin + rayDir * path.y;

  vec3 sSun = normalize(sunPosition - start);

  // if the start point and end point is in shadow just return black
  // vec2 startInt = raySphereIntersection(start, sSun, planetRadius);
  // vec2 endInt = raySphereIntersection(end, sSun, planetRadius);
  // if(
  //   startInt.x < startInt.y &&
  //   startInt.y > 0.0 &&
  //   endInt.x < endInt.y &&
  //   endInt.y > 0.0) {
  //   // return vec3(0.0);
  // }

  float fsteps = float(steps.x);
  float d = (path.y - path.x);
  float ds = d / fsteps;

  vec3 rayleighT = vec3(0.0);
  vec3 mieT = vec3(0.0);
  // begin calculating transmittance via optical depth accumulation
  vec2 primaryDepth = vec2(0.0);

  for (int i = 0; i < steps.x; i++){
    float t = (float(i) + 0.5) / fsteps;
    vec3 pos = mix(start, end, t);
    vec2 odStep = opticalDensity(length(pos), scaleHeights, planetRadius) * ds;
    primaryDepth += odStep;
    vec2 intPlanet2 = raySphereIntersection(pos, sSun, planetRadius);
    // if the ray intersects the planet, no light comes this way
    if(intPlanet2.x < intPlanet2.y && intPlanet2.x >= 0.0) {
      continue;
      // exit = pos + intPlanet2.x * sSun;
      // earthShadow = 0.01;
    }

    // float approachDepth = closestApproachDepth(pos, sSun, planetRadius);
    float earthShadow = 1.0; //clampMix(1.0, 0.0, approachDepth / ds);

    vec2 intAtmosphere2 = raySphereIntersection(pos, sSun, atmosphereRadius);
    vec3 exit = pos + intAtmosphere2.y * sSun;

    float u = umbra(
      pos,
      rApparentSun,
      sunPosition,
      rApparentMoon,
      moonPosition
    );
    vec2 secondaryDepth = opticalDepths(pos, exit, scaleHeights, planetRadius, steps.y);
    // vec2 secondaryDepth = getOpticalDepths(pos, normalize(exit - pos), scaleHeights, planetRadius, atmosphereRadius);
    // vec2 secondaryDepth = vec2(0.0);
    vec2 depth = primaryDepth + secondaryDepth;
    vec4 alpha = vec4(vec3(depth.x), depth.y) * scatteringCoefficients;
    vec3 transmittance = earthShadow * u * exp(- alpha.xyz - alpha.w);

    rayleighT += transmittance * odStep.x;
    mieT += transmittance * odStep.y;
  }

  // phases
  vec2 phases = getPhases(rayDir, sSun, g);
  float rayleighP = phases.x;
  float mieP = phases.y;

  vec4 alpha = vec4(vec3(primaryDepth.x), primaryDepth.y) * scatteringCoefficients;
  vec3 transmittance = exp(-alpha.xyz - alpha.w);
  vec3 sunDiskColor = sunDisk * transmittance;

  vec3 scatter = rayleighT * rayleighP * scatteringCoefficients.xyz + mieT * mieP * scatteringCoefficients.w;
  return vec4(I0 * scatter + sunDiskColor, clamp((primaryDepth.y * mieCoefficient), 0.0, 1.0));
}

void main() {
  vec3 rayDir = normalize(vWorldPosition);
  vec2 intPlanet = raySphereIntersection(rayOrigin, rayDir, planetRadius);

  bool planet_intersected = intersects2(intPlanet);
  if(planet_intersected && intPlanet.x > 0. && intPlanet.x < 1000.) {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  vec4 color = scattering(
    rayOrigin,
    rayDir,
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

  // if (!planet_intersected){
  //   float sm = sunMoonIntensity(
  //     rayDir,
  //     normalize(sunPosition - rayOrigin),
  //     SunAngularRadius,
  //     normalize(moonPosition - rayOrigin),
  //     MoonAngularRadius,
  //     sunIntensity
  //   );
  //   color += vec4(sm, sm, sm, 1.0);
  //   // color += vec4(sm, min(1.0, length(sm)));
  // }

  // if (planet_intersected){
  //   gl_FragColor = vec4(0.0, 0.0, 0.0, opacity);
  //   return;
  // }

  // vec2 p = phases(
  //   RayOrigin,
  //   rayDir,
  //   sunPosition,
  //   mieDirectional
  // );

  // vec3 scatter = vRayleighT * p[0] + vMieT * p[1];
  // vec3 color = sunIntensity * scatter;

  // apply gamma correction
  // color = 0.4 * pow(color, vec3(1.0 / 1.2));
  // Apply exposure.
  // color = 1.0 - exp(-exposure * color);

  // Dithering by hornet: https://www.shadertoy.com/view/MslGR8
  float dither_bit = 8.0;
  float grid_position = fract(dot(gl_FragCoord.xy - vec2(0.5, 0.5), vec2(1.0 / 16.0, 10.0 / 36.0) + 0.25));
  float dither_shift = (0.25) * (1.0 / (pow(2.0, dither_bit) - 1.0));
  vec3 dither_shift_RGB = vec3(dither_shift, -dither_shift, dither_shift); //subpixel dithering
  dither_shift_RGB = mix(2.0 * dither_shift_RGB, -2.0 * dither_shift_RGB, grid_position);

  gl_FragColor = vec4(color.rgb + dither_shift_RGB, color.a); //vec4(color, opacity);
}