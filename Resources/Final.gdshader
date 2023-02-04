shader_type spatial;
render_mode cull_disabled, depth_draw_opaque,diffuse_burley,specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_roughness : hint_roughness_r,filter_linear_mipmap,repeat_enable;

uniform int total_vertices = 48;
uniform int max_tip_rings = 2;
varying float scale_a;

void vertex() {
	int total_rings = max(total_vertices-38, 0);
	total_rings = max(total_rings / 48, 1);
	float uv_step = (1.0/float(total_rings) );
	
	int current_vartex = VERTEX_ID;
	int ring_id = max( current_vartex -18, 0) / 48;
	float scale_uv = UV.x * uv_step;
//	scale_uv = 0.0;
	float scale = min((1.0 - (float(ring_id) / float(total_rings)) ), 1.0);
	scale_a = scale;
	if (current_vartex>=18 && current_vartex < (total_vertices-18)) 
	{
		VERTEX -= NORMAL * (scale - scale_uv)*0.75;
	} 
	else
	{
		VERTEX = vec3(0.0);
	}
}
//void vertex() {
////	int tip_verticles =  max_tip_rings * 48;
//	int vertex_id_no_cap = max(VERTEX_ID-18,0);
//	float uv_step = (1.0/float(max_tip_rings));
//
////	int total_rings = max(total_vertices-38, 0);
////	total_rings = max(total_rings / 48, 1);
//
//	int current_vartex =  vertex_id_no_cap + max_tip_rings*48 - (total_vertices-36) ;
////	int ring_id = max( current_vartex, 0) / 48;
//	int ring_id = int(ceil(float(max( current_vartex, 0)) / 48.0));
//
//	float scale = clamp(( float(ring_id) / float(max_tip_rings) ),0.0, 1.0);
//
//	float scale_uv = (1.0-UV.x) * uv_step * float(bool(scale));
////	scale_uv *= scale;
////	scale_uv = 0.0;
//	scale_a = scale;
//	VERTEX -= NORMAL * clamp(scale+scale_uv,0.0,1.0);
//	if (ring_id >= max_tip_rings)
//	{
//		VERTEX = vec3(0.0);
//	}
//
//}


void fragment() {
	vec2 base_uv = vec2(UV.y,UV.x);
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	METALLIC = 0.0;
	SPECULAR = 0.5;
}
