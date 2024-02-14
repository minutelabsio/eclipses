varying vec3 vWorldPosition;
varying vec2 vUv;
varying vec3 vCameraDirection;
varying vec3 rayOrigin;
varying float SunAngularRadius;
varying float MoonAngularRadius;
varying float MoonAngularRadiusCamera;
varying float altitude;
varying vec3 origin;

uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform float sunRadius;
uniform float moonRadius;
uniform float planetRadius;

void main() {
  vec4 worldPosition = modelMatrix * vec4(position, 1.0);
  vWorldPosition = worldPosition.xyz;
  vUv = uv;
  vCameraDirection = normalize(cameraPosition.xyz - worldPosition.xyz);

  gl_Position = projectionMatrix * modelViewMatrix * worldPosition;
  gl_Position.z = gl_Position.w; // set z to camera.far... not sure why though

  origin = (modelMatrix * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
  rayOrigin = cameraPosition - origin + vec3(0, 1.0, 0);
  altitude = length(rayOrigin) - planetRadius;
  vec3 groundOrigin = normalize(rayOrigin) * planetRadius;

  // angular radii of sun and moon change very little
  SunAngularRadius = asin(sunRadius / distance(sunPosition, groundOrigin));
  MoonAngularRadius = asin(moonRadius / distance(moonPosition, groundOrigin));
  MoonAngularRadiusCamera = asin(moonRadius / distance(moonPosition, rayOrigin));
}
