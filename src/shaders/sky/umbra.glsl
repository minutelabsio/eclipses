#define PI 3.1415926535897932384626433832795

float twoCircleIntersection(float r1, float r2, float d) {
  if(d > (r1 + r2)) {
    return 0.0;
  } else if(d <= abs(r1 - r2)) {
    float r = min(r1, r2);
    return PI * r * r;
  }
  float d2 = d * d;
  vec2 rs = vec2(r1, r2);
  vec2 rs2 = rs * rs;
  float r12mr22 = dot(rs2, vec2(1., -1.));
  float twod = 2.0 * d;
  float twod2 = 2.0 * d2;
  float area = dot(rs2, acos(vec2(d2 + r12mr22, d2 - r12mr22) / (twod * rs))) - 0.5 * sqrt(dot(vec4(-r12mr22, twod2, twod2, -d2), vec4(r12mr22, rs2, d2)));
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

#pragma glslify: export(umbra)