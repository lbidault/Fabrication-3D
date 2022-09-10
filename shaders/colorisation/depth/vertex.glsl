#version 300 es

precision mediump float;

layout(location = 0) in vec3 aPosition;

uniform mat4 uWorldMatrix;
uniform mat4 uLightMatrix;
uniform mat4 uProjectionMatrix;

void main() {
  gl_Position = uProjectionMatrix * uLightMatrix * uWorldMatrix * vec4(aPosition, 1.0);
}