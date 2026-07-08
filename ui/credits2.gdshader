shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Parámetros ajustables desde el Inspector
uniform float scanline_count : hint_range(0.0, 1080.0) = 300.0;
uniform float scanline_opacity : hint_range(0.0, 1.0) = 0.15;
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.4;
uniform float screen_curvature : hint_range(0.0, 1.0) = 0;
uniform vec4 neon_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Función para curvar las coordenadas UV imitando una pantalla CRT esférica
vec2 curve(vec2 uv) {
    uv = (uv - 0.5) * 2.0;
    uv.x *= 1.0 + pow((abs(uv.y) * screen_curvature), 2.0);
    uv.y *= 1.0 + pow((abs(uv.x) * screen_curvature), 2.0);
    uv = (uv / 2.0) + 0.5;
    return uv;
}

void fragment() {
    // 1. Aplicar curvatura a la pantalla
    vec2 crt_uv = curve(SCREEN_UV);
    
    // Cortar los píxeles que queden fuera de la curvatura (bordes negros redondos)
    if (crt_uv.x < 0.0 || crt_uv.x > 1.0 || crt_uv.y < 0.0 || crt_uv.y > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        // 2. Tomar el color original de la pantalla (texto + fondo)
        vec4 text_color = texture(SCREEN_TEXTURE, crt_uv);
        
        // 3. Calcular las Scanlines (Líneas de barrido horizontales)
        float scanline = sin(crt_uv.y * scanline_count * PI * 2.0);
        scanline = (scanline + 1.0) / 2.0; // Normalizar entre 0 y 1
        scanline = mix(1.0, scanline, scanline_opacity);
        
        // 4. Efecto Vignette (Oscurecer las esquinas)
        float vignette = crt_uv.x * crt_uv.y * (1.0 - crt_uv.x) * (1.0 - crt_uv.y);
        vignette = clamp(pow(16.0 * vignette, vignette_intensity), 0.0, 1.0);
        
        // 5. Combinar todo con el tinte neón elegido
        COLOR = text_color * scanline * vignette * neon_tint;
    }
}