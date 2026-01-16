shader_type canvas_item;

uniform float vignette_intensity = 0.4;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 vignette_rgb : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float edge_softness :  hint_range(0.0, 1.0) = 0.3;

uniform sampler2D screen_vec :  hint_screen_texture;

float vignette(vec2 uv){
	// Create rectangular vignette with smooth gradient towards edges
	vec2 center = uv - 0.5;
	float rect_vignette = max(abs(center.x), abs(center.y));
	
	// Smooth gradient falloff - 1.0 at center, 0.0 at edges
	float gradient = 1.0 - smoothstep(0.5 - edge_softness, 0.5, rect_vignette);
	return gradient * vignette_opacity;
}

void fragment(){
	vec4 screen_color = texture(screen_vec, SCREEN_UV);
	
	// Apply vignette darkening with gradient towards edges
	float vignette_factor = vignette(SCREEN_UV);
	vec3 darkened = mix(vignette_rgb. rgb, screen_color.rgb, vignette_factor);
	
	COLOR = vec4(darkened, 1.0);
}