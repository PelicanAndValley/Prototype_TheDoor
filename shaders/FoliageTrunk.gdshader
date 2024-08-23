shader_type spatial;
render_mode cull_disabled, alpha_to_coverage_and_one;

#include "res://shaders/perlin3d.gdshaderinc"


group_uniforms Config;
//uniform float ao_strength;

group_uniforms Albedo;
uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

group_uniforms Normal;
uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale : hint_range(-16, 16) = 1.0;

group_uniforms Roughness;
uniform float roughness : hint_range(0, 1) = 1.0;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;



void vertex() {

}

void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	vec4 roughness_tex = texture(texture_roughness, UV);
	vec4 normal_tex = texture(texture_normal, UV);
	
	ALPHA = albedo_tex.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	NORMAL_MAP = normal_tex.rgb;
	NORMAL_MAP_DEPTH = normal_scale;
	ROUGHNESS = roughness_tex.r * roughness;
	AO = COLOR.g;

	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
