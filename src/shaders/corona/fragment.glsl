varying vec3 vPosition;
varying vec3 vNormal;
varying vec2 vUv;
uniform sampler2D uCoronaTexture;
uniform float uOpacity;
uniform float uSunIntensity;

void main(){
  vec3 view = normalize(cameraPosition - vPosition);
  vec3 c = vec3(dot(view, vNormal), 0, 0);
  vec2 offset = vec2(-0.002, -0.0058);
  vec2 xy = vUv + offset;
  vec4 corona = texture2D(uCoronaTexture, xy);
  vec3 one = normalize(vec3(1.0));
  float alpha = dot(one, corona.xyz);
  float cutoff = 0.05;
  if (alpha < cutoff){
    alpha = 0.0;
  }
  float intensity = 1e-2 * uSunIntensity;
  gl_FragColor = intensity * vec4(corona.xyz, alpha * uOpacity); //vec4(1.0, 0.0, 0.0, 1.0);
}