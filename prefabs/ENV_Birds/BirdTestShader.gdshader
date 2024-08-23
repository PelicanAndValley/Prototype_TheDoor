shader_type spatial;

#include "res://shaders/perlin3d.gdshaderinc"

uniform float time_scale = 1.0;
uniform float lateral_strength = 0.2;
uniform float pivot = 11.0;
uniform float wave = 1.0;
uniform float twist = 1.4;

void vertex() {
	float time = TIME * time_scale;
	float offset_pos = _perlin3dNoiseFunc(vec3(0.2, 0.2, time / 190.0), cos(time / 400.0));
	float pivot_angle = cos(time) * 1.1 * pivot;
	float twist_angle = cos(time * 11.0) * 1.0 * twist;
	mat2 twist_matrix = mat2(vec2(cos(twist_angle), -sin(twist_angle)), vec2(sin(twist_angle), cos(twist_angle)));
	VERTEX.z += cos(time) * lateral_strength;
	VERTEX.xy = mix(VERTEX.xy, twist_matrix * VERTEX.xy, (COLOR.b * 0.48));
	VERTEX.y += cos(time * offset_pos);
	VERTEX.y += cos(time * 11.0) * (COLOR.r / 1.2);
	VERTEX.y += cos(time * 11.0) / 12.0;
}

void fragment() {
	ALBEDO = vec3 (0.05, 0.05, 0.05);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
