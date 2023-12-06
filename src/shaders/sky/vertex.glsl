varying vec3 vWorldPosition;
varying vec2 vUv;
varying vec3 vCameraDirection;
varying vec3 rayOrigin;
varying float SunAngularRadius;
varying float MoonAngularRadius;

uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform float sunRadius;
uniform float moonRadius;
uniform float planetRadius;
uniform float altitude;

void main() {
  vec4 worldPosition = modelMatrix * vec4(position, 1.0);
  vWorldPosition = worldPosition.xyz;
  vUv = uv;
  vec4 cameraPosition = modelViewMatrix * vec4(cameraPosition, 1.0);
  vCameraDirection = normalize(cameraPosition.xyz - worldPosition.xyz);

  gl_Position = projectionMatrix * modelViewMatrix * worldPosition;
  gl_Position.z = gl_Position.w; // set z to camera.far... not sure why though

  rayOrigin = vec3(0, planetRadius + altitude + 1.0, 0);

  // angular radii of sun and moon change very little
  SunAngularRadius = asin(sunRadius / length(sunPosition - rayOrigin));
  MoonAngularRadius = asin(moonRadius / length(moonPosition - rayOrigin));
}
