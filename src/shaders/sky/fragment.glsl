uniform vec3 topColor;
uniform vec3 bottomColor;
uniform float offset;
uniform float exponent;
uniform float opacity;

#pragma glslify: dither = require(glsl-dither/2x2)

varying vec3 vWorldPosition;

void main() {

  float h = normalize(vWorldPosition + offset).y;
  gl_FragColor = vec4(mix(bottomColor, topColor, max(pow(max(h, 0.0), exponent), 0.0)), opacity);

}