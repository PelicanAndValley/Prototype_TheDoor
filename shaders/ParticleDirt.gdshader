shader_type spatial;
render_mode blend_mix, shadows_disabled, specular_disabled, vertex_lighting;

group_uniforms Mask;
uniform sampler2D texture_mask : source_color, filter_linear_mipmap, repeat_enable;

group_uniforms Color;
uniform sampler2D gradient;
uniform float mix_amount = 1.0;

void vertex() {
	// Billboard Mode: Particles
	mat4 mat_world = mat4(
			normalize(INV_VIEW_MATRIX[0]),
			normalize(INV_VIEW_MATRIX[1]),
			normalize(INV_VIEW_MATRIX[2]),
			MODEL_MATRIX[3]);
	mat_world = mat_world * mat4(
			vec4(cos(INSTANCE_CUSTOM.x), -sin(INSTANCE_CUSTOM.x), 0.0, 0.0),
			vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0),
			vec4(0.0, 0.0, 1.0, 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_MATRIX = VIEW_MATRIX * mat_world;

	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	vec2 base_uv = UV * 1.0;
	vec4 mask_tex = texture(texture_mask, UV);
	float greyscale_value = dot(mask_tex.rgb, vec3(0.299, 0.587, 0.114));
	vec3 sampled_color = texture(gradient, vec2(greyscale_value, 0.0)).rgb;

	ALPHA = mask_tex.r;
	ALBEDO = sampled_color;
}
