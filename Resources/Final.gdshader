shader_type spatial;

uniform float total_vertices = 2.0;

void fragment() {
	// Place fragment code here.
}
void vertex() {
	float total_rings = max(total_vertices - 36.0,0.0)/48.0;
	float ring_id = max(float(VERTEX_ID) - 18.0, 0.0)/48.0;
	float scale_uv = UV.x * 0.2;
	VERTEX -= NORMAL * ((1.0-(ring_id / total_rings)) - scale_uv);
}