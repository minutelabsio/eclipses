varying vec3 vPosition;
varying vec3 vNormal;
varying vec2 vUv;

void main(){
  vPosition = (modelMatrix * vec4(position, 1.0)).xyz;
  vUv = uv;
  vNormal = normal;
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}