shader_type spatial; // Indicate that this shader is for 3D objects

// Declare a texture uniform. Note: No need for 'hint_albedo' in spatial shaders
uniform sampler2D albedo_texture;

// Declare uniform variables for scrolling. Vec2 can hold two values: U (horizontal) and V (vertical) scroll speeds.
uniform vec2 scroll_speed = vec2(0.1, 0.0); // Adjust the scroll speed as necessary
uniform float transparency = 0.5; // Adjust transparency level (0.0 - fully transparent, 1.0 - fully opaque)
uniform vec2 uv_scale = vec2(1.0, 1.0); // Uniform variable for UV scaling

void fragment() {
    vec2 uv = UV * uv_scale; // Apply UV scaling
    uv += scroll_speed * TIME; // Scroll the texture over time
    vec4 tex_color = texture(albedo_texture, uv);

    tex_color.a *= transparency; // Apply transparency
    ALBEDO = tex_color.rgb;
    ALPHA = tex_color.a;
}
