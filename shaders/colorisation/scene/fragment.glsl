#version 300 es

precision mediump float;

in vec3 vPosition;
in vec3 vNormal;
in mat4 vViewMatrix;
in vec2 vTex;
in vec4 vLightViewPositions[5];

out vec4 fragColor;

struct Directional {
  vec3 color;
  vec3 direction;
  float intensity;
};

struct Point {
  vec3 color;
  vec3 position;
  float intensity;
};

struct Spot {
  vec3 color;
  vec3 position;
  vec3 direction;
  float angle;
  float intensity;
};

uniform float uAmbient;
uniform float uDiffuse;
uniform float uSpecular;
uniform vec3 uColor;
uniform sampler2D uShadowMap;
uniform float uReflectance;
uniform float uIlluminable;
uniform vec3 uCurrent;

uniform Directional directional;
uniform Point point;
uniform Spot spot;

vec3 calcDirectionalColor(Directional directional, float shadowFactor) {

  vec3 dir = normalize((vViewMatrix * vec4(directional.direction, 0.0)).xyz);

  //diffuse
  float diffuseFactor = max(-dot(vNormal, dir), 0.0);

  //reflet
  vec3 cameraDirection = normalize(-vPosition);
  vec3 reflectedDirection = normalize(reflect(dir, vNormal));
  float specularFactor = max(dot(cameraDirection, reflectedDirection), 0.0);

  float intensity = (uAmbient + shadowFactor * (uDiffuse * diffuseFactor + uSpecular * uReflectance * pow(specularFactor, 4.0))) * directional.intensity;
  return vec3(uColor.x * directional.color.x, uColor.y * directional.color.y, uColor.z * directional.color.z) * intensity;
}

vec3 calcPointColor(Point point, float shadowFactor) {
  vec3 pPos = (vViewMatrix * vec4(point.position, 1.0)).xyz;
  float dist = distance(pPos, vPosition);

  //diffuse
  float diffuseFactor = max(dot(vNormal, normalize(pPos - vPosition)), 0.0);

  //reflet
  vec3 cameraDirection = normalize(-vPosition);
  vec3 reflectedDirection = normalize(reflect(normalize(pPos - vPosition), vNormal));
  float specularFactor = max(-dot(cameraDirection, reflectedDirection), 0.0);

  float intensity = (uAmbient * 0.02 + shadowFactor * 0.5 * (uDiffuse * diffuseFactor + 0.5 * uSpecular * uReflectance * pow(specularFactor, 1.0)) / pow(dist, 1.0)) * point.intensity;
  return vec3(uColor.x * point.color.x, uColor.y * point.color.y, uColor.z * point.color.z) * intensity;
}

vec3 calcSpotColor(Spot spot, float shadowFactor) {
  vec3 dir = normalize((vViewMatrix * vec4(spot.direction, 0.0)).xyz);
  vec3 sPos = (vViewMatrix * vec4(spot.position, 1.0)).xyz;
  float dist = distance(sPos, vPosition);
  vec3 from_light_source = vPosition - sPos;
  float inside = 0.0;
  if(dot(normalize(from_light_source), dir) >= cos(spot.angle)) {
    inside = 1.0;
  }
  //diffuse
  float diffuseFactor = max(dot(vNormal, normalize(sPos - vPosition)), 0.0) * max(-dot(vNormal, dir), 0.0);//

  //reflet
  vec3 cameraDirection = normalize(-vPosition);
  vec3 reflectedDirection = normalize(reflect(dir, vNormal));
  float specularFactor = max(dot(cameraDirection, reflectedDirection), 0.0);

  float intensity = (uAmbient * 0.02 + shadowFactor * (uDiffuse * inside * diffuseFactor + 0.5 * uSpecular * inside * uReflectance * pow(specularFactor, 4.0)) / pow(dist, 1.0)) * spot.intensity;

  return vec3(uColor.x * spot.color.x, uColor.y * spot.color.y, uColor.z * spot.color.z) * intensity;
}

float calcShadow(vec4 position, bool zTest) {
  float shadowFactor = 1.0;
  vec3 pos = position.xyz;
  pos.xy = pos.xy / position.w * 0.5 + 0.5;
  vec3 value = texture(uShadowMap, pos.xy).xyz;
  if(zTest) {
    if(pos.x >= 0.0 && pos.y >= 0.0 && pos.x <= 1.0 && pos.y <= 1.0) {
      if(distance(value, uColor) <= 0.01 || length(value) == 0.0) {
        shadowFactor = 0.0;
      }
    } else {
      shadowFactor = 0.0;
    }
  } else {
    if(pos.x >= 0.0 && pos.y >= 0.0 && pos.x <= 1.0 && pos.y <= 1.0) {
      if(distance(value, uColor) <= 0.01 || length(value) == 0.0) {
        shadowFactor = 0.0;
      }
    } else {
      shadowFactor = 0.0;
    }
  }
  return 1.0 - shadowFactor;
}

float calcPointShadow(vec4 position, int face) {
  float shadowFactor = 1.0;
  vec3 pos = position.xyz;
  pos.xy = pos.xy / position.w * 0.5 + 0.5;

  float a = 0.0;
  float b = 0.0;

  if(face == 1) {
    a = 0.25;
  }
  if(face == 2) {
    a = 0.5;
  }
  if(face == 3) {
    a = 0.75;
  }
  if(face == 4) {
    b = 0.25;
  }

  pos.x = pos.x * 0.25 + a;
  pos.y = pos.y * 0.25 + b;
  vec3 value = texture(uShadowMap, pos.xy).xyz;
  if(pos.x >= 0.0 + a && pos.y >= 0.0 + b && pos.x <= 0.25 + a && pos.y <= 0.25 + b && pos.z >= 0.0) {
    if(distance(value, uColor) <= 0.01 || length(value) == 0.0) {
      shadowFactor = 0.0;
    }
  } else {
    shadowFactor = 0.0;
  }

  return 1.0 - shadowFactor;
}

void main() {
  if(uIlluminable <= 0.5) {
    fragColor = vec4(uColor, 1.0);
  } else {
    float shadowFactor = 1.0;
    if(uCurrent.y == 0.0) {
      if(uCurrent.x == 0.0) {
        shadowFactor = calcShadow(vLightViewPositions[0], true);
      } else {
        shadowFactor = calcShadow(vLightViewPositions[0], false);
      }

    } else {
      for(int i = 0; i < 5; i++) {
        shadowFactor *= calcPointShadow(vLightViewPositions[i], i);
      }
    }
    vec3 directionalColor = calcDirectionalColor(directional, shadowFactor);
    vec3 pointColor = calcPointColor(point, shadowFactor);
    vec3 spotColor = calcSpotColor(spot, shadowFactor);
    fragColor = vec4(uCurrent.x * directionalColor + uCurrent.y * pointColor + uCurrent.z * spotColor, 1.0);
  }
}