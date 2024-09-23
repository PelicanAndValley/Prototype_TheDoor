#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 8, local_size_y = 8, local_size_z = 8) in;


// The wind forces and their locations
layout(set = 0, binding = 0, std430) buffer WindForcesBuffer {
    vec3 positions[];
    vec3 normals[];
}
wind_forces;

// 3D image containing velocity vectors of wind corresponding to 3d position
layout(set = 0, binding = 1) restrict writeonly uniform image3D wind_normal;


void main() {

    imageStore(
        wind_normal,
        ivec3(gl_GlobalInvocationID.xyz),
        vec4(gl_GlobalInvocationID.x / 128.0, gl_GlobalInvocationID.y / 128.0, gl_GlobalInvocationID.z / 128.0, 1)
    );

}