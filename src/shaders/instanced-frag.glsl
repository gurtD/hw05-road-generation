#version 300 es
precision highp float;

in vec4 fs_Col;
in vec4 fs_Pos;
in vec4 fs_Nor;
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

void main()
{
    /*
    vec4 lightVec = vec4(10.0, -15.0, 0.0, 1.0);
    float diffuseTerm = dot(normalize(fs_Nor), normalize(lightVec));
    diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);
    float ambientTerm = 0.6 ;
    float lightIntensity = diffuseTerm + ambientTerm;
    vec4 diffuseColor = fs_Col;
    //out_Col = vec4(1.0, 1.0, 1.0, 1.0);
    
    out_Col = fs_Col;

    out_Col = vec4(diffuseColor.rgb * lightIntensity, 1.0);

    float t = dot(normalize(fs_Nor), normalize(vec4(lightVec)));

    vec3 a = vec3(0.5f, 0.5f, 0.5f);
    vec3 b = vec3(0.5f, 0.5f, 0.5f);
    vec3 c = vec3(1.0f, 1.0f, 1.0f);
    vec3 d = vec3(0.0f, 0.33f, 0.67f);
    out_Col = vec4((a + b * cos(2.0 * 3.14f * (c * t + d))) * lightIntensity, 1.0);
    */

    float landNoise = fbm(fs_Pos.x , fs_Pos.y, 1.0 ) * 0.4;
    if (landNoise < 0.3) {
        out_Col = vec4(1.0 / 255.0, 8.0 / 255.0, 144.0 / 255.0, 1.0);
    } else {
        out_Col = vec4(0.0, 0.0, 0.0, 1.0);
    }
    
}
