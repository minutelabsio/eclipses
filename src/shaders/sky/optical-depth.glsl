vec2 opticalDensity(float z, vec2 scaleHeights, float planetRadius) {
  float h = z - planetRadius;
  return exp(-h / scaleHeights);
}

// optical depth from start to end in the atmosphere
vec2 opticalDepths(vec3 start, vec3 end, vec2 scaleHeights, float planetRadius, int steps) {
  vec2 od = vec2(0.0);
  float fsteps = float(steps);
  float ds = length(end - start) / fsteps;
  for (int i = 0; i < steps; i++) {
    float t = (float(i) + 0.5) / fsteps;
    vec3 p = mix(start, end, t);
    od += opticalDensity(length(p), scaleHeights, planetRadius) * ds;
  }
  return od;
}

#pragma glslify: export(opticalDepth)
