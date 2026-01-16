shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.0, 0.18, 0.0, 1.0);
uniform float intensity = 0.25;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float light = (UV.x + UV.y) * 0.5;
	float shade = (light - 0.5) * intensity;
	
	COLOR = base_color + shade;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
