shader_type canvas_item;

// Parámetros de velocidad ajustables desde el Inspector
uniform float velocidad_color = 2.5;
uniform float velocidad_glitch = 12.0;
uniform float intensidad_corte = 0.015;

float rand(float co) {
    return fract(sin(co * 12.9898) * 43758.5453);
}

void fragment() {
    vec2 uv = UV; // Usamos las coordenadas locales del panel, NO SCREEN_UV
    
    // 1. EFECTO GLITCH LOCAL (Afecta solo al marco)
    float tiempo_bloque = floor(TIME * velocidad_glitch);
    float linea_ruido = rand(floor(uv.y * 35.0) + tiempo_bloque);
    
    if (linea_ruido > 0.88) {
        uv.x += sin(TIME * velocidad_glitch) * intensidad_corte;
    }

    // Leemos la textura local del StyleBoxTexture (tu borde fragmentado blanco)
    vec4 tex_color = texture(TEXTURE, uv);
    
    // Si el píxel de la imagen del marco es transparente, lo descartamos inmediatamente
    if (tex_color.a < 0.01) {
        discard;
    }

    // 2. CONFIGURACIÓN DE TU PALETA NEÓN (Tus morados oscuros exactos)
    vec3 color_morado_rosado = vec3(0.45, 0.05, 0.40); 
    vec3 color_azul_morado = vec3(0.05, 0.12, 0.55);

    // 3. FLUJO DE COLOR DIAGONAL LOCAL
    float factor_mezcla = sin((uv.x * 2.0) + (uv.y * 1.5) + (TIME * velocidad_color));
    factor_mezcla = (factor_mezcla + 1.0) / 2.0;
    
    vec3 color_final = mix(color_morado_rosado, color_azul_morado, factor_mezcla);
    
    // Pintamos únicamente las líneas del marco respetando su opacidad nativa
    COLOR = vec4(color_final * 1.5, tex_color.a);
}