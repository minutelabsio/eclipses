attribute float size;
attribute vec4 color;
varying vec4 vColor;
varying vec3 vPosition;

void main() {
  vColor = color * size * 0.62;
  vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);
      // gl_PointSize = 6e9 * size * ( 250.0 / -mvPosition.z );
  gl_PointSize = size * 1.8;
  vPosition = mvPosition.xyz;
  gl_Position = projectionMatrix * mvPosition;
}