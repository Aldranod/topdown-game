shader_type canvas_item;

// This shader only shows the silhouette where the player is obscured
// by something on a specific layer (like the tree).
//render_mode unshaded;

// This line tells Godot to ONLY draw this sprite where a light is hitting it
render_mode light_only; 

uniform vec4 silhouette_color : source_color = vec4(1.0, 1.0, 1.0, 0.5);

void fragment() {
    // Get the texture of the player
    vec4 col = texture(TEXTURE, UV);
    // Apply the silhouette color to the player's shape
    COLOR = vec4(silhouette_color.rgb, col.a * silhouette_color.a);
}