varying vec3 vWorldPosition;

void main() {

  vec4 worldPosition = modelMatrix * vec4(position, 1.0);
  vWorldPosition = worldPosition.xyz;

  gl_Position = projectionMatrix * modelViewMatrix * worldPosition;
  gl_Position.z = gl_Position.w; // set z to camera.far... not sure why though
}
