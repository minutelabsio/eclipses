#define PI 3.1415926535897932384626433832795

vec2 opticalDensity(float z, vec2 scaleHeights, float planetRadius) {
  float h = max(0.0, z - planetRadius);
  return exp(-h / scaleHeights);
}

// optical depth from start to end in the atmosphere
vec2 opticalDepths(vec3 start, vec3 end, vec2 scaleHeights, float planetRadius, int steps) {
  vec2 od = vec2(0.0);
  float fsteps = float(steps);
  float ds = length(end - start) / fsteps;
  for(int i = 0; i < steps; i++) {
    float t = (float(i) + 0.5) / fsteps;
    vec3 p = mix(start, end, t);
    od += opticalDensity(length(p), scaleHeights, planetRadius) * ds;
  }
  return od;
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
  return max(0.0, 1.0 - area / totalArea);
}

vec3[2] attenuation(
  vec3 rayOrigin,
  vec3 rayDir,
  // rayleigh xyz, mie w
  vec4 scatteringCoefficients,
  vec2 scaleHeights,
  float planetRadius,
  // sun position
  vec3 sunPosition,
  float sunAngularRadius,
  // moon position
  vec3 moonPosition,
  float moonAngularRadius,
  // really just a cuttoff for the atmosphere
  float atmosphereRadius,
  ivec2 steps
) {
  // planetRadius *= 0.6;
  // determine intersections with the planet, atmosphere, etc
  vec2 intPlanet = raySphereIntersection(rayOrigin, rayDir, planetRadius * 0.6);
  bool planet_intersected = (intPlanet.x <= intPlanet.y && intPlanet.x > 0.0);

  // Ray starts inside the planet -> return 0
  if(intPlanet.x < 0.0 && intPlanet.y > 0.0) {
    return vec3[2](vec3(0.0), vec3(0.0));
  }

  vec3 sSun = normalize(sunPosition - rayOrigin);

  vec2 path = raySphereIntersection(rayOrigin, rayDir, atmosphereRadius);
  // Ray does not intersect the atmosphere (on the way forward) at all;
  // exit early.
  if(path.x > path.y || path.y <= 0.0) {
    return vec3[2](vec3(0.0), vec3(0.0));
  }

  // always start atmosphere ray at viewpoint if we start inside atmosphere
  path.x = max(path.x, 0.0);

  // if the planet is intersected, set the end of the ray to the planet
  // surface.
  path.y = planet_intersected ? intPlanet.x : path.y;

  // if we have a very short path, we're probably just looking at ground just ignore
  // if (path.y - path.x < 20.0){
  //   return vec3(0.0);
  // }

  vec3 rayleighT = vec3(0.0);
  vec3 mieT = vec3(0.0);
  // begin calculating transmittance via optical depth accumulation
  vec2 primaryDepth = vec2(0.0);

  float fsteps = float(steps.x);
  vec3 start = rayOrigin + rayDir * path.x;
  vec3 end = rayOrigin + rayDir * path.y;
  float ds = (path.y - path.x) / fsteps;

  for(int i = 0; i < steps.x; i++) {
    float t = (float(i) + 0.5) / fsteps;
    vec3 pos = mix(start, end, t);
    vec2 odStep = opticalDensity(length(pos), scaleHeights, planetRadius) * ds;
    primaryDepth += odStep;

    vec2 intPlanet2 = raySphereIntersection(pos, sSun, planetRadius);
    float earthShadow = 1.0;
    // if it intersects the planet, we're in shadow
    if(intPlanet2.x < intPlanet2.y && intPlanet2.y > 0.0) {
      // not sure if this is the best thing to do
      earthShadow = 1.0 - smoothstep(0.0, 0.3, max(0.0, intPlanet2.y - intPlanet2.x) / planetRadius);
    }
    vec2 intAtmosphere2 = raySphereIntersection(pos, sSun, atmosphereRadius * 0.6);
    vec3 exit = pos + intAtmosphere2.y * sSun;
    vec2 secondaryDepth = opticalDepths(pos, exit, scaleHeights, planetRadius, steps.y);
    float g = umbra(pos, sunAngularRadius, sunPosition, moonAngularRadius, moonPosition);
    vec2 depth = primaryDepth + secondaryDepth;
    vec4 alpha = vec4(vec3(depth.x), depth.y) * scatteringCoefficients;
    vec3 transmittance = earthShadow * g * exp(-alpha.xyz - alpha.w);

    rayleighT += transmittance * odStep.x;
    mieT += transmittance * odStep.y;
  }

  rayleighT *= scatteringCoefficients.xyz;
  mieT *= scatteringCoefficients.w;
  return vec3[2](rayleighT, mieT);
}

#pragma glslify: export(attenuation)