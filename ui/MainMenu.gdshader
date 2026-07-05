shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float intensidad_lineas = 0.12;
uniform float glitch_rgb = 0.0025; // Controla el desfase cyberpunk de colores

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Desfase de canales para emular aberración cromática en bordes neón
    float r = texture(SCREEN_TEXTURE, vec2(uv.x - glitch_rgb, uv.y)).r;
    float g = texture(SCREEN_TEXTURE, uv).g;
    float b = texture(SCREEN_TEXTURE, vec2(uv.x + glitch_rgb, uv.y)).b;
    
    vec4 color_base = vec4(r, g, b, 1.0);
    
    // Scanlines horizontales sutiles
    float scanline = sin(uv.y * 500.0 * PI);
    scanline = (scanline + 1.0) / 2.0;
    scanline = mix(1.0 - intensidad_lineas, 1.0, scanline);
    
    COLOR = color_base * scanline;
}
