#version 300 es

uniform mat4 u_ViewProj;
uniform float u_Time;

uniform mat3 u_CameraAxes; // Used for rendering particles as billboards (quads that are always looking at the camera)
// gl_Position = center + vs_Pos.x * camRight + vs_Pos.y * camUp;

in vec4 vs_Pos; // Non-instanced; each particle is the same quad drawn in a different place
in vec4 vs_Nor; // Non-instanced, and presently unused
in vec4 vs_Col; // An instanced rendering attribute; each particle instance has a different color
in vec3 vs_Translate; // Another instance rendering attribute used to position each quad instance in the scene
in vec2 vs_UV; // Non-instanced, and presently unused in main(). Feel free to use it for your meshes.
in vec4 vs_Transform0;
in vec4 vs_Transform1;
in vec4 vs_Transform2;
in vec4 vs_Transform3;


out vec4 fs_Nor;
out vec4 fs_Col;
out vec4 fs_Pos;

void main()
{
    fs_Nor = vs_Nor;
    mat4 transform = mat4(vs_Transform0, vs_Transform1, vs_Transform2, vs_Transform3);
    
    //fs_Pos = vs_Pos;

    mat4 scale = mat4(1.0);
    float scalar = 1.0;
    scale[0][0] = scalar * 0.01;
    scale[1][1] = scalar * 0.025;
    scale[2][2] = 0.001;

    
    fs_Col = vec4(vs_Transform0.xyz, 1.0);
    
    //gl_Position = u_ViewProj * transform * scale * vs_Pos;
    fs_Pos = transform * scale * vs_Pos;
    gl_Position = transform * scale * vs_Pos;
}
