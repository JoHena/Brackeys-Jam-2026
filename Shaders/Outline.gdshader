shader_type spatial;

render_mode blend_mix;

uniform sampler2D albedo_texture : source_color;
uniform vec4 albedo_color : source_color = vec4(1.0);

uniform float glow_intensity : hint_range(0.0, 10.0) = 0.0;
uniform vec4 highlight_color : source_color = vec4(0.99, 0.65, 0.14, 1.0);

void fragment() {
    vec4 tex_color = texture(albedo_texture, UV) * albedo_color;

    ALBEDO = mix(
        tex_color.rgb,
        highlight_color.rgb,
        glow_intensity * 0.15
    );

    EMISSION = highlight_color.rgb * glow_intensity;

    ALPHA = tex_color.a;
}