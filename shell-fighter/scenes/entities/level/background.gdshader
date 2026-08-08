shader_type canvas_item;
uniform vec2 camera_position;


void fragment() {
	COLOR = texture(TEXTURE, UV + camera_position);
}
