#version 300 es

precision mediump float;

layout(location = 0) in vec3 aPosition;
layout(location = 1) in vec3 aNormal;

uniform vec3 uCurrent;
uniform mat4 uWorldMatrix;
uniform mat4 uViewMatrix;
uniform mat4 uProjectionMatrix;
uniform mat4 uLightMatrix;
uniform mat4 uLightProjectionMatrix;
uniform mat4 uPointLightMatrices[5];

out vec3 vPosition;
out vec2 vTex;
out vec3 vNormal;
out mat4 vViewMatrix;
out vec4 vLightViewPositions[5];

void main() {
  vec4 mvPos = uViewMatrix * uWorldMatrix * vec4(aPosition, 1.0);
  vec4 mvNorm = uViewMatrix * uWorldMatrix * vec4(aNormal, 0.0);
  vPosition = mvPos.xyz;
  vNormal = normalize(mvNorm.xyz);
  vViewMatrix = uViewMatrix;
  vTex = vec2(aPosition.x * 0.5 + 0.5, aPosition.z * 0.5 + 0.5);
  if(uCurrent.y == 0.0) {
    vLightViewPositions[0] = uLightProjectionMatrix * uLightMatrix * uWorldMatrix * vec4(aPosition, 1.0);
  } else {
    for(int i = 0; i < 5; i++) {
      vLightViewPositions[i] = uLightProjectionMatrix * uPointLightMatrices[i] * uWorldMatrix * vec4(aPosition, 1.0);
    }
  }
  gl_Position = uProjectionMatrix * mvPos;
}