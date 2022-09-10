#version 300 es

precision mediump float;

struct Directional {
  vec3 color;
  vec3 direction;
  float intensity;
};

uniform int uIsTextured;
uniform vec3 uColor;
uniform float uTransparency;
uniform int uIsPanel;
uniform sampler2D uSampler;
uniform sampler2D uCameraA;
uniform sampler2D uCameraB;
uniform Directional directional;

in vec2 vTextureCoord;
in vec3 vNormal;
out vec4 fragColor;

vec4 calcDirectional(vec3 normal, vec4 color) {
  float ambientFactor = 0.5;
  vec3 directionN = normalize(directional.direction);
  vec3 normalN = normalize(normal);
  float diffuseFactor = min(directional.intensity * max(-dot(directionN, normalN), 0.0), 1.0 - ambientFactor);

  return vec4((ambientFactor + diffuseFactor) * directional.color * color.xyz, uTransparency);
}

vec2 g(vec2 V) {
  return vec2(3.0 * V.x - 1.0, 4.0 * V.y - 1.0);
}

vec2 h(vec2 V, int type) {
  float wx = 200.0 / 1082.0 / 0.695;
  float dx = 0.0205;
  if(type == 1) {
    dx += wx / 2.0 + 0.029;
  }
  float wy = 200.0 / 732.0 / 0.695;
  float dy = 0.027;
  return vec2(2.0 / (3.0 * wx) * V.x + 1.0 / 3.0 * (1.0 - 2.0 * (1.0 / 3.0 + dx) / wx), 1.0 / (2.0 * wy) * V.y + 1.0 / 4.0 * (1.0 - 2.0 * (1.0 / 4.0 + dy) / wy));
}

void main() {
  vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
  if(uIsPanel == 1) {
    vec2 coordsA = g(h(vTextureCoord.xy, 0));
    vec2 coordsB = g(h(vTextureCoord.xy, 1));
    if(0.0 <= coordsA.x && coordsA.x <= 1.0 && 0.0 <= coordsA.y && coordsA.y <= 1.0) {
      color = texture(uCameraA, vec2(coordsA.x, 1.0 - coordsA.y));
    } else if(0.0 <= coordsB.x && coordsB.x <= 1.0 && 0.0 <= coordsB.y && coordsB.y <= 1.0) {
      color = texture(uCameraB, vec2(coordsB.x, 1.0 - coordsB.y));
    } else {
      color = texture(uSampler, vec2(vTextureCoord.x, vTextureCoord.y));
    }
  } else if(uIsTextured == 1) {
    color = texture(uSampler, vec2(vTextureCoord.x, vTextureCoord.y));
  } else {
    color = vec4(uColor, 1.0);
  }
  fragColor = calcDirectional(vNormal, color);
}
