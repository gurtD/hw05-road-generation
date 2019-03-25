#version 300 es
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;
uniform float u_Time;

in vec2 fs_Pos;
out vec4 out_Col;

float noise(vec2 n) {
    return (fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453));
}

float interpNoise2D(float x, float y, float seed) {
    float intX = floor(x);
    float fractX = fract(x);
    float intY = floor(y);
    float fractY = fract(y);
    //float seed = 1.0;

    float v1 = noise(seed * vec2(intX, intY));
    float v2 = noise(seed * vec2(intX + 1.0, intY));
    float v3 = noise(seed * vec2(intX, intY + 1.0));
    float v4 = noise(seed * vec2(intX + 1.0, intY + 1.0));

    float i1 = mix(v1, v2, fractX);
    float i2 = mix(v3, v4, fractX);
    return mix(i1, i2, fractY);
    
}



float fbm(float x, float y, float seed)
{
    float total = 0.0;
    float persistance = 0.5f;
    int octaves = 8;

    for (int i = 0; i < octaves; i++) {
        float freq = pow(2.f,  float(i));
        float amp = pow(persistance, float(i));

        total += (interpNoise2D(x * freq, y * freq, seed)) * amp;
    }
    return (total + 1.0f) / 2.0f;
}
vec3 land_grandient(float height) {
  vec3 white = vec3(1.0, 1.0, 1.0);
  vec3 green = vec3(15.0 / 255.0, 66.0 / 255.0, 15.0 / 255.0);
  vec3 blue = vec3(1.0 / 255.0, 8.0 / 255.0, 144.0 / 255.0);

  if ( height <= 0.3 ) {
      return blue;
  } else {
      //return mix(green, white, pow((height - 0.3) / 0.7, 0.8));
      return mix(green, white, (height - 0.3) * 2.0);
  }
}

void main() {
  float landNoise = fbm(fs_Pos.x , fs_Pos.y, 1.0 ) * 0.4;
  float popNoise = pow(fbm(fs_Pos.y, fs_Pos.x, 2.3) - 0.5, 1.5);
  

 
  vec4 pop = vec4(mix(vec3(63.0 / 255.0, 12.0 / 255.0, 79.0 / 255.0), vec3(1.0, 1.0, 1.0), popNoise), 1.0);
  vec4 land = vec4(land_grandient(landNoise), 1.0);

  out_Col = mix(land, pop, sin(mod(u_Time / 50.0, 3.14)));
  
  //out_Col = vec4(0.5 * (fs_Pos + vec2(1.0)), 0.0, 1.0);
  //out_Col = vec4(land_grandient(landNoise), 1.0);
}
