shader_type spatial;
render_mode cull_disabled, depth_prepass_alpha, alpha_to_coverage_and_one;

#include "res://shaders/perlin3d.gdshaderinc"

group_uniforms Config;
//uniform float ao_strength;

group_uniforms Wind;
uniform bool has_wind = true; //Currently does fuck all
uniform float wind_strength : hint_range(0.0, 10.0) = 1.0;
uniform float wind_speed: hint_range (0.0, 10.0) = 1.0;

group_uniforms Albedo;
uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

group_uniforms Normal;
uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale : hint_range(-16, 16) = 1.0;

group_uniforms Roughness;
uniform float roughness : hint_range(0, 1) = 1.0;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

group_uniforms Backlight;
uniform float backlight_boost: hint_range (0, 1) = 0.25;
uniform float backlight_strength: hint_range(0, 12) = 6.0;
uniform vec4 backlight_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float backlight : hint_range(0, 1) = 1.0;
uniform sampler2D texture_backlight : filter_linear_mipmap, repeat_enable;

void vertex() {
	float wind_strength_adjust = wind_strength * 0.1;
	float offset_pos = _perlin3dNoiseFunc(vec3((COLOR.b + COLOR.b + COLOR.b)*(UV.s*90.0)*80.0, 0.0, TIME*wind_speed), wind_strength_adjust);
	float offset_neg = _perlin3dNoiseFunc(vec3((COLOR.b + COLOR.b + COLOR.b)*(UV.s*30.0)*80.0, 0.0, TIME*wind_speed), wind_strength_adjust);
 	VERTEX.x += offset_pos * COLOR.b;
	VERTEX.x -= offset_neg * COLOR.b;
	VERTEX.z += offset_pos * COLOR.b;
	VERTEX.z -= offset_neg * COLOR.b;
	VERTEX.y += (offset_pos) * COLOR.b;
	VERTEX.y -= (offset_neg * 2.0) * COLOR.b;
}

void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	vec4 roughness_tex = texture(texture_roughness, UV);
	vec4 normal_tex = texture(texture_normal, UV);
	vec4 backlight_tex = texture(texture_backlight, UV);

	
	ALPHA = albedo_tex.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	NORMAL_MAP = normal_tex.rgb;
	NORMAL_MAP_DEPTH = normal_scale;
	ROUGHNESS = roughness_tex.r * roughness;
	AO = COLOR.g;
	BACKLIGHT = vec3(backlight_tex.rgb * backlight_tint.rgb * (COLOR.b * backlight_strength)) * (COLOR.g + backlight_boost);
	RIM = 0.4;
	RIM_TINT = 0.6;
	



	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
