shader_type spatial;
render_mode unshaded, cull_back, depth_draw_opaque, specular_disabled;

// Assign this from script or the editor to the SubViewport's texture.
uniform sampler2D screen_texture : source_color, hint_default_black;

group_uniforms crt;
uniform float scanline_count : hint_range(50.0, 800.0) = 240.0;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float curvature : hint_range(0.0, 10.0) = 3.0;
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.6;
uniform float chromatic_aberration : hint_range(0.0, 0.02) = 0.0025;

group_uniforms look;
uniform float brightness : hint_range(0.0, 3.0) = 1.1;
uniform float emission_strength : hint_range(0.0, 5.0) = 1.2;
uniform float flicker_speed : hint_range(0.0, 20.0) = 8.0;
uniform float flicker_strength : hint_range(0.0, 0.2) = 0.03;
uniform float noise_strength : hint_range(0.0, 0.2) = 0.02;


void fragment() {
	// Barrel-distort the UVs so the image bulges like an old CRT tube.
	vec2 centered = UV - 0.5;
	float dist2 = dot(centered, centered) * curvature;
	vec2 uv = UV + centered * dist2;

	// Outside the curved bounds -> plain black bezel, no sampling.
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		ALBEDO = vec3(0.0);
		EMISSION = vec3(0.0);
	}

	// Slight per-channel offset for a cheap chromatic aberration fringe.
	float r = texture(screen_texture, uv + vec2(chromatic_aberration, 0.0)).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv - vec2(chromatic_aberration, 0.0)).b;
	vec3 color = vec3(r, g, b);

	// Horizontal scanlines.
	float scanline = sin(uv.y * scanline_count * PI) * 0.5 + 0.5;
	color *= mix(1.0, scanline, scanline_intensity);

	// Radial vignette darkening the corners.
	float vignette = clamp(1.0 - vignette_strength * pow(length(centered) * 1.4, 2.0), 0.0, 1.0);
	color *= vignette;

	// Subtle brightness flicker, like an aging power supply.
	float flicker = 1.0 + sin(TIME * flicker_speed) * flicker_strength;
	color *= flicker;

	// Cheap animated grain.
	float n = fract(sin(dot(uv * TIME, vec2(12.9898, 78.233))) * 43758.5453);
	color += (n - 0.5) * noise_strength;

	color *= brightness;

	ALBEDO = color;
	EMISSION = color * emission_strength; // pairs nicely with WorldEnvironment glow
}