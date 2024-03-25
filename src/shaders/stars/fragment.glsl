varying vec4 vColor;
uniform float exposure;
uniform float time;
uniform float depth;
varying vec3 vPosition;

#pragma glslify: fbm = require(../sky/fbm.glsl)

void main() {
  float brightness = fbm(normalize(vPosition) * 1000. + 0.001 * time);
  gl_FragColor = vColor * mix(1., brightness, depth); //1.0 - exp(-exposure * vec4( vColor ));
}