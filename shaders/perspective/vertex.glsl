#version 300 es

precision mediump float;

layout(location = 0) in vec3 aVertexPosition;
layout(location = 1) in vec2 aTextureCoord;
layout(location = 2) in vec3 aVertexNormal;

uniform mat4 uWorldMatrix;
uniform mat4 uViewMatrix;
uniform mat4 uProjectionMatrix;

out vec3 vPosition;
out vec2 vTextureCoord;
out vec3 vNormal;

void main() {
  vPosition = (uWorldMatrix * vec4(aVertexPosition, 1.0)).xyz;
  vTextureCoord = aTextureCoord;
  vNormal = (uWorldMatrix * vec4(aVertexNormal, 0.0)).xyz;
  gl_Position = uProjectionMatrix * uViewMatrix * vec4(vPosition, 1.0);
}