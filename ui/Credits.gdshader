shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float intensidad_lineas : hint_range(0.0, 1.0) = 0.12; // Un poco más sutil para los textos
uniform float glitch_rgb : hint_range(0.0, 0.01) = 0.0015; // Desfase neón controlado

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Separación de canales (Aberración Cromática Cyberpunk)
    float r = texture(SCREEN_TEXTURE, vec2(uv.x - glitch_rgb, uv.y)).r;
    float g = texture(SCREEN_TEXTURE, uv).g;
    float b = texture(SCREEN_TEXTURE, vec2(uv.x + glitch_rgb, uv.y)).b;
    
    vec4 color_base = vec4(r, g, b, 1.0);
    
    // Líneas de escaneo horizontales fijas y ultra nítidas
    float scanline = sin(uv.y * 450.0 * PI);
    scanline = (scanline + 1.0) / 2.0;
    scanline = mix(1.0 - intensidad_lineas, 1.0, scanline);
    
    COLOR = color_base * scanline;
}