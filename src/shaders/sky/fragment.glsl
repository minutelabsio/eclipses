varying vec3 vWorldPosition;
varying vec2 vUv;
varying vec3 vCameraDirection;
varying vec3 rayOrigin;
varying float SunAngularRadius;
varying float MoonAngularRadius;
varying float MoonAngularRadiusCamera;
varying float altitude;
varying float sunVisibleArea;

uniform bool fisheye;
uniform float time;

uniform sampler2D coronaTexture;
uniform sampler2D moonTexture;
uniform float opticalDepthMapSize;
uniform float sunRadius;
uniform float moonRadius;
uniform vec3 planetColor;

uniform float opacity;
uniform vec3 moonPosition;
uniform float sunIntensity;
uniform vec3 sunPosition;
uniform float planetRadius;
uniform float atmosphereThickness;
uniform vec3 rayleighCoefficients;
uniform float rayleighScaleHeight;

uniform vec3 mieCoefficients;
uniform vec3 mieWavelengthResponse;
uniform float mieScaleHeight;
uniform float mieDirectional;
uniform float mieBaseline;

uniform float ozoneLayerHeight;
uniform float ozoneLayerWidth;
uniform vec3 ozoneCoefficients;

uniform float exposure;
uniform int iSteps;
uniform int jSteps;

uniform float windSpeed;
uniform float cloudZ;
uniform float cloudSize;
uniform float cloudMie;
uniform float cloudThickness;
uniform float cloudThreshold;
uniform float cloudAbsorption;

#define PI 3.1415926535897932384626433832795
#pragma glslify: fbm = require(./fbm)
#pragma glslify: snoise2 = require(glsl-noise/simplex/2d)
#pragma glslify: snoise3 = require(glsl-noise/simplex/3d)
#pragma glslify: cnoise2 = require(glsl-noise/classic/2d)
#pragma glslify: cnoise3 = require(glsl-noise/classic/3d)
#pragma glslify: umbra = require(./umbra)
#pragma glslify: Intersection = require(glsl-ray-sphere/intersection)
#pragma glslify: sphereIntersection = require(glsl-ray-sphere/rsi, Intersection=Intersection)

const float ONE_OVER_E = exp(-1.0);
const float THREE_OVER_16_PI = 3.0 / (16.0 * PI);
const float THREE_OVER_8_PI = 3.0 / (8.0 * PI);
const float ONE_OVER_FOUR_PI = 1.0 / (4.0 * PI);
const float MIN_STEP_SIZE = 1e4;

float invLerp(float a, float b, float v) {
  return clamp((v - a) / (b - a), 0.0, 1.0);
}

float remap(float value, float low1, float high1, float low2, float high2) {
  float t = invLerp(low1, high1, value);
  return mix(low2, high2, t);
}

float opticalDensityTent(float x, float height, float width) {
  return max(0., 1. - 2. * abs(x - height) / width);
	// The ozone layer is represented as a tent function with a width of 30km, centered around an altitude of 25km.
  // return max(0., 1. - abs(h - 25000.0) / 15000.0);
}

vec3 opticalDensity(float x) {
  return clamp(
    vec3(
      exp(-x / vec2(rayleighScaleHeight, mieScaleHeight)),
      opticalDensityTent(x, ozoneLayerHeight, ozoneLayerWidth)
    ),
  0., 5.);
}

// optical depth from start to end in the atmosphere
vec3 opticalDepths(vec3 start, vec3 end, int steps) {
  vec3 od = vec3(0.0);
  float fsteps = float(steps);
  vec3 r = end - start;
  float d = length(r);
  r /= d;
  float ds = d / fsteps;
  vec3 dr = ds * r;
  vec3 pos = start - 0.5 * dr;
  for(int i = 0; i < steps; i++) {
    pos += dr;
    od += opticalDensity(length(pos) - planetRadius) * ds;
  }
  return od;
}

float smoothcircle(vec3 ray, float angularRadius, vec3 centerDir){
  // this way gives weird artifacts because the angle is so small it leads to floating point errors
  // float angle = acos(dot(centerDir, ray));
  // float b = boundary * angularRadius;
  // return 1.0 - smoothstep(angularRadius - b, angularRadius + b, angle);
  // float y = length(ray - centerDir);
  // float r = sin(angularRadius);
  // float b = 0.001;
  // return smoothstep(r + b, r - b, y);
  float d = distance(ray, centerDir);
  float px = fwidth(d); // roughly a pixel
  float r = max(angularRadius, px);
  // dim as sun gets smaller
  float i = smoothstep(0., px, angularRadius);
  float delta = 0.01 * angularRadius; //0.1 * fwidth(d); //fwidth(d); //0.5 * fwidth(d);
  return i * smoothstep(r, r - delta, d);
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

float rayleighPhase(float mu){
  return THREE_OVER_16_PI + THREE_OVER_16_PI * mu * mu;
}

float drainPhase(float mu,float alpha, float g){
  float gg = g * g;
  float mumu = mu * mu;
  return ONE_OVER_FOUR_PI * (1.0 - gg) / (1.0 + alpha * (1.0 + 2.0 * gg) / 3.0) *
    (1.0 + alpha * mumu) / pow(1.0 + gg - 2.0 * mu * g, 1.5);
}

float miePhase(float mu, float g){
  // phases
  float mumu = mu * mu;
  float gg = g * g;
  return THREE_OVER_8_PI * ((1.0 - gg) * (mumu + 1.0)) / (pow(1.0 + gg - 2.0 * mu * g, 1.5) * (2.0 + gg));
}

float phaseHGD(float mu, float ghg, float gd, float alpha, float wd){
  return (1. - wd) * drainPhase(mu, 0., ghg) + wd * drainPhase(mu, alpha, gd);
}

// new phase function from https://research.nvidia.com/labs/rtr/approximate-mie/publications/approximate-mie.pdf
// d is particle size from 5 - 50 in microns
float getMieHGD(float mu, float d){
  float ghg = exp(-0.0990567 / (d - 1.67154));
  float gd = exp(-2.20679 / (d + 3.91029) - 0.428934);
  float alpha = exp(3.62489 - 8.29288 / (d + 5.52825));
  float wd = exp(-0.599085 / (d - 0.641583) - 0.665888);
  float mieP = phaseHGD(mu, ghg, gd, alpha, wd);
  return mieP;
}

vec2 getPhasesHGD(float mu, float d){
  // phases
  float mumu = mu * mu;
  float rayleighP = rayleighPhase(mu);
  float mieP = getMieHGD(mu, d);
  return vec2(rayleighP, mieP);
}

vec3 angleDependentMie(vec3 response, float mu, float g){
  float ghg = 0.37;
  float gd = 0.96;
  float alpha = 1.18;
  vec3 wd = g * response / max(response.x, max(response.y, response.z));
  vec3 miePhase = vec3(
    // miePhaseHGD(mu, ghg, gd, alpha, wd.x),
    // miePhaseHGD(mu, ghg, gd, alpha, wd.y),
    // miePhaseHGD(mu, ghg, gd, alpha, wd.z)
    miePhase(mu, wd.x),
    miePhase(mu, wd.y),
    miePhase(mu, wd.z)
  );
  return miePhase;
}

vec2 getPhases(float mu, float g){
  // phases
  float mumu = mu * mu;
  float rayleighP = THREE_OVER_16_PI + THREE_OVER_16_PI * mumu;
  float mieP = miePhase(mu, g);
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

vec3 sunMoon(vec3 rayDir, vec3 sSun, float sunAngularRadius, vec3 sMoon, float moonAngularRadius, float I0){
  float mu = dot(rayDir, sSun);
  if (mu < 0.999){
    return vec3(0.0);
  }
  mu = max(mu, 0.99);
  // Color of the solar disk (that isn't blocked by the moon)
  float sunDisk = 0.0;
  sunDisk = smoothcircle(rayDir, sunAngularRadius, sSun);

  float g = 0.9997; //clampMix(0.99993, 0.999, (acos(dot(sSun, sMoon)) - 0.001) / 0.02);
  float gg = g * g;
  float mumu = mu * mu;
  // sunDisk = (0.001) * THREE_OVER_8_PI * ((1.0 - gg) * (mumu + 1.0)) / (pow(1.0 + gg - 2.0 * mu * g, 1.5) * (2.0 + gg));

  float moonDisk = smoothcircle(rayDir, moonAngularRadius * 1.0, sMoon);

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

float luma(vec3 c){
  return dot(c, vec3(0.299, 0.587, 0.114));
}

float coronaValue(vec3 rayDir, vec3 sSun, float sunAngularRadius){
  float intensity = 5e-2 * remap(sunVisibleArea, 0., 0.01, 1., 0.);
  if (intensity < 1e-5){
    // return 0.0;
  }
  vec2 xy = squash(rayDir, sSun);
  xy.x *= -1.;
  // eclipse2017 corona
  // vec2 uv = .56 * xy / sunAngularRadius / vec2(3.17, 2.556) + vec2(0.4956, 0.492);
  // simulated corona
  vec2 uv = .6 * xy / sunAngularRadius / 15. + vec2(0.5, 0.5);
  if(uv.x <= 0. || uv.x >= 1. || uv.y <= 0.0 || uv.y >= 1.) {
    return 0.0;
  }
  // prevent streaking at edges of texture
  vec4 corona = texture2D(coronaTexture, uv);
  // color correction
  corona.rgb = pow(corona.rgb, vec3(2.2));
  float l = luma(corona.rgb);
  return intensity * l;
}

float moonValue(vec3 rayDir, vec3 sMoon, float moonAngularRadius){
  if (textureSize(moonTexture, 0).x == 1){
    // create little bumps on the edge of the moon
    vec2 y = normalize(squash(rayDir, sMoon));
    float r = moonAngularRadius * (1. - 0.002 * cnoise2(15. * y));
    return smoothcircle(rayDir, r, sMoon);
  }
  vec2 xy = squash(rayDir, sMoon);
  // xy is the vector from the center of the moon to the point on the moon
  // uv should be calculated so that the height of the texture is the angular diameter of the moon
  vec2 uv = 0.5 * xy / moonAngularRadius + vec2(0.5, 0.5);
  // if (uv.x <= 0. || uv.x >= 1. || uv.y <= 0.0 || uv.y >= 1.){
  //   return 0.0;
  // }
  vec4 moon = texture2D(moonTexture, uv);
  return moon.r * smoothcircle(rayDir, moonAngularRadius, sMoon);
}

const float bloomFactor = 8e-6;
float sunMoonIntensity(vec3 rayDir, vec3 sSun, float sunAngularRadius, vec3 sMoon, float moonAngularRadius){
  // if (distance(sSun, rayDir) > 0.07){
  //   return 0.0;
  // }

  // simple circle sun
  float sun = smoothcircle(rayDir, sunAngularRadius, sSun);
  // some texture on the sun
  vec2 sunxy = squash(rayDir, sSun) / sunAngularRadius;
  // sunspots (not that you'd really see them)
  sun *= (1. - 0.2 * step(0.8, cnoise2(15. * sunxy)));
  // flairs
  // sun += smoothcircle(rayDir, sunAngularRadius * 0.9, sSun) *
  //   smoothstep(0.3, 0.9, fbm(vec3(sunxy, 0.) * 20.)) *
  //   clampMix(0., 1., sin(atan(sunxy.y, sunxy.x) * 10. * cnoise2(sunxy * 1.)));
  float corona = coronaValue(rayDir, sSun, sunAngularRadius);
  sun += corona;

  float moon = moonValue(rayDir, sMoon, moonAngularRadius);
  return mix(sun, 0.0, moon);
  // return step(.9, sun - moon);
}

float nextStep(const float d, const float ds, const int i) {
  float current = float(i) * ds;
  if (current > d) {
    return -1.0;
  }
  float next = current + ds;
  // steps up until the last are just ds
  return next > d ? d - current : ds;
}
vec4 scattering(
  vec3 rayOrigin,
  vec3 rayDir,
  // rayleigh xyz, mie w
  vec3 rayleighCoefficients,
  vec3 mieCoefficients,
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
  float sunDisk = sunMoonIntensity(
    rayDir,
    normalize(sunPosition - rayOrigin),
    SunAngularRadius,
    normalize(moonPosition - rayOrigin),
    MoonAngularRadiusCamera
  );

  Intersection atmosInt = sphereIntersection(rayOrigin, rayDir, atmosphereRadius);

  // Ray does not intersect the atmosphere (on the way forward) at all;
  // exit early.
  if (atmosInt.hits == 0) {
    return vec4(I0 * vec3(sunDisk), step(0.01, length(sunDisk)));
  }

  float rApparentSun = tan(SunAngularRadius);
  float rApparentMoon = tan(moonAngularRadius);

  vec2 path = vec2(atmosInt.t0, atmosInt.t1);
  // always start atmosphere ray at viewpoint if we start inside atmosphere
  path.x = max(path.x, 0.0);

  // if the planet is intersected, set the end of the ray to the planet
  // surface.
  // determine intersections with the planet, atmosphere, etc
  Intersection planetInt = sphereIntersection(rayOrigin, rayDir, planetRadius);
  bool planet_intersected = planetInt.hits > 1; // only count exterior intersection
  path.y = planet_intersected ? planetInt.t0 : path.y;

  // if planet intersected, no light comes from the sun
  sunDisk = planet_intersected ? 0.0 : sunDisk;

  vec3 start = rayOrigin + rayDir * path.x;
  vec3 end = rayOrigin + rayDir * path.y;

  vec3 sSun = normalize(sunPosition - start);

  vec3 rayleighT = vec3(0.0);
  vec3 mieT = vec3(0.0);
  // begin calculating transmittance via optical depth accumulation
  vec3 primaryDepth = vec3(0.0);

  float fsteps = float(steps.x);
  float d = (path.y - path.x);
  float ds = d / fsteps;
  vec3 dr = rayDir * ds;
  vec3 pos = start + 0.5 * dr;
  // trick from https://github.com/Fewes/MinimalAtmosphere/blob/master/Assets/Atmosphere/Shaders/Atmosphere.cginc
  // We can reduce the number of atmospheric samples required to converge by spacing them exponentially closer to the camera.
	// This breaks space view however, so let's compensate for that with an exponent that "fades" to 1 as we leave the atmosphere.
  float observerHeight = length(rayOrigin) - planetRadius;
  float factor = planet_intersected ? 0. : 8.;
  float sampleDistributionExponent = 1. + factor * clamp(1. - observerHeight / atmosphereThickness, 0., 1.);
  float prevRayT = 0.0;
  float avgUmbra = 0.0;
  for (int i = 0; i < steps.x; i++){
    float t = d * pow(float(i) / fsteps, sampleDistributionExponent);
    ds = t - prevRayT;
    prevRayT = t;
    dr = rayDir * ds;
    pos += dr;
    vec3 odStep = opticalDensity(length(pos) - planetRadius) * ds;
    primaryDepth += odStep;

    // has minimum brightness for corona
    float u = max(1e-2, umbra(pos, rApparentSun, sunPosition, rApparentMoon, moonPosition));
    avgUmbra += u;

    Intersection atmosOut = sphereIntersection(pos, sSun, atmosphereRadius);
    vec3 exit = pos + atmosOut.t1 * sSun;

    vec3 secondaryDepth = opticalDepths(pos, exit, steps.y);
    // vec2 secondaryDepth = getOpticalDepths(pos, normalize(exit - pos), scaleHeights, planetRadius, atmosphereRadius);
    // vec2 secondaryDepth = vec2(0.0);
    vec3 depth = primaryDepth + secondaryDepth;
    vec3 alpha = depth.x * rayleighCoefficients + depth.y * mieCoefficients + depth.z * ozoneCoefficients;
    vec3 transmittance = exp(-alpha);
    vec3 scatter = u * transmittance;

    rayleighT += scatter * odStep.x;
    mieT += scatter * odStep.y;
  }

  avgUmbra /= float(steps.x);

  // phases
  float mu = dot(rayDir, sSun);
  float rphase = rayleighPhase(mu);
  // vec2 phases = vec2(rayleighPhase(mu), clamp(1e2 * g, 0., 1. / length(mieCoefficients)));
  float mieNorm = length(angleDependentMie(mieWavelengthResponse, 1., g));
  mieNorm = mieNorm == 0.0 ? 1.0 : mieNorm;
  vec3 mphase = angleDependentMie(mieWavelengthResponse, mu, g) / mieNorm;

  // scatter direct light from the sundisk
  vec3 alpha = primaryDepth.x * rayleighCoefficients + primaryDepth.y * mieCoefficients + primaryDepth.z * ozoneCoefficients;
  vec3 transmittance = exp(-alpha);
  vec3 sunDiskColor = sunDisk * transmittance;
  // clouds
  float cloudAmount = 0.0;
  vec3 cloud = vec3(0.0);
  float cloudAbsorptionAmount = 0.0;
  if (!planet_intersected && cloudThickness >= 0.01){
    float cloudHeight = cloudZ * atmosphereThickness;
    Intersection intCloud = sphereIntersection(rayOrigin, rayDir, planetRadius + cloudHeight);
    if (intCloud.isInside){
      float cloudNorm = miePhase(1., cloudMie);
      float cloudPhase = 4. * miePhase(mu, cloudMie) / cloudNorm;
      float cloudRefl = 4. * miePhase(mu, -0.1);
      vec3 cloudPoint = rayOrigin + intCloud.t1 * rayDir;
      Intersection intPlanet = sphereIntersection(cloudPoint, rayDir, planetRadius);
      vec3 cloudLayer = cloudSize * 900. * cloudPoint / atmosphereRadius;
      cloudAmount = cloudThickness * smoothstep(0., 1.0, fbm(cloudLayer + windSpeed * time) - cloudThreshold);
      // float cloudAmount = 2. * getPhases(rayDir, sSun, 0.5 + 0.4 * fbm(cloudLayer * 20.)).y;
      cloudAbsorptionAmount = clamp(cloudAbsorption * cloudAmount, 0., 1.);
      float brightness = remap(intPlanet.t1 - abs(intPlanet.t0), 0., 0.08 * planetRadius, 1., 0.);
      cloud =  clamp(0.1 * cloudAmount * mieCoefficients * (brightness * (1. - cloudAbsorption) * (cloudPhase + cloudRefl) * (rayleighT + mieT)), 0., 1.);
    }
  }

  // clouds below for gas giants
  // if (planetRadius > 5e6 && planet_intersected){
  //   float cloudNorm = miePhase(1., cloudMie);
  //   float cloudPhase = 4. * miePhase(mu, cloudMie);
  //   float cloudRefl = 4. * miePhase(mu, -0.1);
  //   vec3 cloudPoint = rayOrigin + path.y * rayDir;
  //   // cloudPoint += 20. * cnoise3(cloudPoint / planetRadius);
  //   vec2 planetInt = raySphereIntersection(cloudPoint, sSun, planetRadius - 1.);
  //   float cloudMinBrightness = mix(1e-5, 0., remap(planetInt.y - abs(planetInt.x), 0., 0.03 * planetRadius, 0., 1.));
  //   vec3 cloudLayer = cloudSize * 4000. * cloudPoint / atmosphereRadius;
  //   cloudAmount = cloudThickness * smoothstep(0., 1.0, fbm(cloudLayer + windSpeed * time + 10.) - cloudThreshold);
  //   // fade as we get higher
  //   float k = remap(length(rayOrigin) - planetRadius, 0., atmosphereThickness, 0., 1.);
  //   cloudAmount = mix(cloudAmount, 0., k);
  //   cloudAbsorptionAmount = clamp(cloudAbsorption * cloudAmount, 0., 1.);
  //   float brightness = remap(planetInt.y - abs(planetInt.x), 0., 0.08 * planetRadius, 1., 0.);
  //   cloud += clamp(0.1 * cloudAmount * mieCoefficients * (brightness * (1. - cloudAbsorption) * (cloudPhase + cloudRefl) * (rayleighT + mieT)), 0., 1.);
  // }

  // final scattering
  vec3 scatter = rayleighT * rphase * rayleighCoefficients + mieT * (mieBaseline + mphase) * mieCoefficients;
  // scatter = clamp(scatter, vec3(0.0), vec3(I0)) / sqrt(fsteps);
  // opacity of the atmosphere
  vec3 color = (scatter + sunDiskColor);
  float opacity = dot(primaryDepth.xy, vec2(0.2 * length(rayleighCoefficients), length(mieCoefficients))) + cloudAbsorptionAmount;
  if(!planet_intersected) {
    // this is a fudge to help hide stars in the daytime when lots of light is scattered
    opacity += clampMix(0., 1., 100. * length(color) + cloudAbsorptionAmount);
    // the stars twinkle :)
    // moved twinkle to stars shader
    // opacity += clampMix(0., 1.0, primaryDepth.x / 1000.) * fbm(rayDir * 100. + 500. * time);
  } else {
    // if looking at the planet from orbit, this ensures a dark shadow
    opacity = mix(1., opacity, avgUmbra);
  }
  // add the clouds
  color = color * (1. - cloudAbsorptionAmount) + cloud;
  return vec4(I0 * clamp(color, 0.0, 1.0), clamp(opacity, 0.0, 1.0));
}

void main() {
  vec3 rayDir = normalize(vWorldPosition);
  if (fisheye){
    // lay it out on a circle use uvs
    float r = 1.1 * length(vUv - 0.5); // add a little bit of padding
    float cosphi = cos(PI * r);
    float theta = -clamp(atan(vUv.y - 0.5, vUv.x - 0.5), -PI, PI);
    // float cosphi = remap(r, 0., 1., 1., -1.);
    float sinphi = sqrt(1. - min(1., cosphi * cosphi));
    rayDir = vec3(sinphi * cos(theta), cosphi, sinphi * sin(theta));
    // debug angles
    // gl_FragColor = vec4(rayDir + 1.0, 1.0);
    // return;

  }

  Intersection intPlanet = sphereIntersection(rayOrigin, rayDir, planetRadius);

  // if the ray intersects the planet, return planet color
  bool planet_intersected = intPlanet.hits > 1;
  float z = altitude / atmosphereThickness;
  if (z < 0.025){
    if(planet_intersected) {
      gl_FragColor = vec4(planetColor, 1.);
      return;
    }
  }

  vec4 color = scattering(
    rayOrigin,
    rayDir,
    rayleighCoefficients,
    mieCoefficients,
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

  // as we get closer to the planet, the atmosphere should get darker
  if (planet_intersected){
    float k = remap(z, 0.025, 0.05, 0., 1.);
    color = mix(vec4(planetColor, 1.), color, k);
  } else {
    // color = color * (1.0 + 0.8 * fbm(vUv * 100.));
  }

  // hdr
  // color.rgb = 4. * (1. - exp(-color.rgb * 1.0));

  // Dithering by hornet: https://www.shadertoy.com/view/MslGR8
  float dither_bit = 8.0;
  float grid_position = fract(dot(gl_FragCoord.xy - vec2(0.5, 0.5), vec2(1.0 / 16.0, 10.0 / 36.0) + 0.25));
  float dither_shift = (0.25) * (1.0 / (pow(2.0, dither_bit) - 1.0));
  vec3 dither_shift_RGB = vec3(dither_shift, -dither_shift, dither_shift); //subpixel dithering
  dither_shift_RGB = mix(2.0 * dither_shift_RGB, -2.0 * dither_shift_RGB, grid_position);

  // reduce color banding
  color.rgb += dither_shift_RGB * length(color.rgb) * 4.;

  gl_FragColor = color;
}