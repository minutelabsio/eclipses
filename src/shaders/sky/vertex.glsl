varying vec3 vWorldPosition;
varying vec2 vUv;
varying vec3 vCameraDirection;

void main() {
  vec4 worldPosition = modelMatrix * vec4(position, 1.0);
  vWorldPosition = worldPosition.xyz;
  vUv = uv;
  vec4 cameraPosition = modelViewMatrix * vec4(cameraPosition, 1.0);
  vCameraDirection = normalize(cameraPosition.xyz - worldPosition.xyz);

  gl_Position = projectionMatrix * modelViewMatrix * worldPosition;
  gl_Position.z = gl_Position.w; // set z to camera.far... not sure why though
}
