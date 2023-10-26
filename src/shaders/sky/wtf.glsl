#define PI 3.1415926535897932384626433832795
#define MIN_STEP_SIZE 0.00001
// #define iSteps 4
// #define jSteps 8
#define RED vec3(1.0, 0.0, 0.0)
#define GREEN vec3(0.0, 1.0, 0.0)
#define BLUE vec3(0.0, 0.0, 1.0)

const float THREE_OVER_16_PI = 3.0 / (16.0 * PI);
const float THREE_OVER_8_PI = 3.0 / (8.0 * PI);

vec2 solveQuadratic(float a, float b, float c) {
  // Solve a quadratic equation of the form ax^2 + bx + c = 0
  // Returns a vec2 containing the two solutions.
  // If there is no solution, x > y
  float discr = b * b - 4.0 * a * c;
  if(discr < 0.0) {
    return vec2(1e5, -1e5);
  } else if(discr == 0.0) {
    float x0 = -0.5 * b / a;
    return vec2(x0, x0);
  } else {
    float sqrtdiscr = sqrt(discr);
    float q = (b > 0.0) ? -0.5 * (b + sqrtdiscr) : -0.5 * (b - sqrtdiscr);
    float x0 = q / a;
    float x1 = c / q;
    if(x0 > x1) {
      return vec2(x1, x0);
    } else {
      return vec2(x0, x1);
    }
  }
}

vec2 rsi(vec3 origin, vec3 ray, float radius) {
    // ray-sphere intersection that assumes
    // the sphere is centered at the origin.
  float a = dot(ray, ray);
  float b = 2.0 * dot(ray, origin);
  float c = dot(origin, origin) - (radius * radius);
  return solveQuadratic(a, b, c);
}

float circleIntersection(float r1, float r2, float d) {
  if(d > r1 + r2) {
    return 0.0;
  } else if(d <= abs(r1 - r2)) {
    float r = min(r1, r2);
    return PI * r * r;
  }
  float d2 = d * d;
  float r12 = r1 * r1;
  float r22 = r2 * r2;
  // float r1mr2 = r1 - r2;
  // float r1pr2 = r1 + r2;
  float r12mr22 = r12 - r22;
  float twod = 2.0 * d;
  float twod2 = 2.0 * d2;
  // float area = r12 * acos((r12mr22 + d2) / (twod * r1))
  //   + r22 * acos((d2 - r12mr22) / (twod * r2))
  //   - 0.5 * sqrt((d + r1 - r2) * (d - r1 + r2) * (-d + r1 + r2) * (d + r1 + r2));
  // float area = r12 * acos((r12mr22 + d2) / (twod * r1))
  //   + r22 * acos((d2 - r12mr22) / (twod * r2))
  //   - 0.5 * sqrt(-r12mr22 * r12mr22 + twod2 * r12 + twod2 * r22 - d2 * d2);
  vec2 r1r2 = vec2(r1, r2);
  float area = dot(r1r2 * r1r2, acos(vec2(d2 + r12mr22, d2 - r12mr22) / (twod * r1r2))) - 0.5 * sqrt(dot(vec4(-r12mr22, twod2, twod2, -d2), vec4(r12mr22, r12, r22, d2)));
  return area;
}

float eclipseFactor(vec3 ri, float thetaSun, vec3 pSun, float thetaMoon, vec3 pMoon) {
  // calculate the amount of the sun that is unobstructed by the moon
  vec3 sSun = normalize(pSun - ri);
  vec3 sMoon = normalize(pMoon - ri);
  float d = length(sSun - sMoon);
  float rSun = tan(thetaSun);
  float rMoon = tan(thetaMoon);
  float area = circleIntersection(rSun, rMoon, d);
  float totalArea = PI * rSun * rSun;
  return max(0.0, 1.0 - area / totalArea);
}

// 3.0 / ( 16.0 * pi )
const float THREE_OVER_SIXTEENPI = 0.05968310365946075;
		// 1.0 / ( 4.0 * pi )
const float ONE_OVER_FOURPI = 0.07957747154594767;

vec4 atmosphere(
  vec3 r,
  vec3 r0,
  vec3 pSun,
  float rSun,
  vec3 pMoon,
  float rMoon,
  float iSun,
  float rPlanet,
  float rAtmos,
  vec3 kRlh,
  float kMie,
  float shRlh,
  float shMie,
  float g,
  int iSteps,
  int jSteps
) {

  vec3 outColor = vec3(0.5);
  r = normalize(r);

    // Calculate the step size of the primary ray.
  vec2 p = rsi(r0, r, rAtmos);

    // There are a few cases to distinguish:
    // 0a: The ray starts outside the atmosphere and does not intersect it.
    //     Return 0.
    // 0b: The ray starts inside the planet. Return 0.
    // 0c: The ray intersects the atmosphere at t < 0. Return 0.
    //
    // If isect_planet.y < 0, set isect_planet.y = 1e16 and
    // isect_planet.x = -1e16 to treat it as non-intersection.
    //
    // 1: The ray starts outside the atmosphere and intersects it at t > 0,
    //    but does not intersect the planet.
    //    Ray from p.x to p.y.
    // 2: The ray starts outside the atmosphere and intersects it at t > 0 and
    //    intersects the planet.
    //    Ray from p.x to isect_planet.x.
    // 3: The ray starts inside the atmosphere and does not intersect the
    //    planet.
    //    Ray from 0 to p.y.
    // 4: The ray starts inside the atmosphere and intersects the planet at
    //    t > 0.
    //    Ray from 0 to isect_planet.x.

  vec2 isect_planet = rsi(r0, r, rPlanet);
  bool planet_intersected = (isect_planet.x < isect_planet.y && isect_planet.y > 0.0);

    // Ray starts inside the planet -> return 0
  if(isect_planet.x <= 0.0 && planet_intersected) {
    return vec4(isect_planet.y, -isect_planet.x/10., -isect_planet.y, 1.0);
  }

  // angular radii of sun and moon
  float thetaSun = asin(rSun / length(pSun - r0));
  float thetaMoon = asin(rMoon / length(pMoon - r0));

  float dSun = 0.0;
  float sundisk = 0.0;

  if(!planet_intersected) {
    bool inMoon = step(thetaMoon, acos(dot(normalize(pMoon - r0), r))) < 1.;
    if(inMoon) {
      // moon color
    } else if((dSun = acos(dot(normalize(pSun - r0), r))) < thetaSun * 5.0) {
      // corona color
      // float sunAngularCos = dot(normalize(pSun - r0), r);
      // float sundisk = smoothstep(sunAngularCos, sunAngularCos + 2e-5, cos(thetaSun));

      // if (dSun < thetaSun) {
      //   // sun color
      //   outColor += vec3(iSun);
      // }
      float sunAngularCos = dot(normalize(pSun - r0), r);
    }
  }

    // Ray does not intersect the atmosphere (on the way forward) at all;
  // exit early.
  if(p.x > p.y || p.y <= 0.0) {
    outColor += vec3(iSun * (sundisk));
    return vec4(outColor, 1.0);
  }


  return vec4(outColor, 1.0);
}

#pragma glslify: export(atmosphere)