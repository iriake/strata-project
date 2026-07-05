shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform float velocidad_color = 2.5;
uniform float velocidad_glitch = 12.0;
uniform float intensidad_corte = 0.015;
uniform float grosor_borde : hint_range(0.0, 5.0) = 1.5; // Controla el ancho del borde de las letras

float rand(float co) {
    return fract(sin(co * 12.9898) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // 1. EFECTO GLITCH
    float tiempo_bloque = floor(TIME * velocidad_glitch);
    float linea_ruido = rand(floor(uv.y * 35.0) + tiempo_bloque);
    if (linea_ruido > 0.88) {
        uv.x += sin(TIME * velocidad_glitch) * intensidad_corte;
    }

    // 2. DETECCIÓN DE BORDES PARA LAS LETRAS (Outline Shader integrado)
    vec4 tex_color = texture(screen_texture, uv);
    vec2 size = SCREEN_PIXEL_SIZE * grosor_borde;
    
    // Muestreamos los 4 puntos cardinales vecinos para buscar transparencias
    float alpha_borde = tex_color.a;
    alpha_borde += texture(screen_texture, uv + vec2(0.0, size.y)).a;
    alpha_borde += texture(screen_texture, uv - vec2(0.0, size.y)).a;
    alpha_borde += texture(screen_texture, uv + vec2(size.x, 0.0)).a;
    alpha_borde += texture(screen_texture, uv - vec2(size.x, 0.0)).a;
    
    // Si la suma de alphas vecinos es mayor que 0 pero el centro está vacío (o es fondo), es un borde
    bool es_borde = (alpha_borde > 0.0 && tex_color.a < 0.9);

    if (tex_color.a < 0.01 && !es_borde) {
        discard;
    }

    // 3. CONFIGURACIÓN DE COLORES PARA EL RELLENO (Tus morados oscuros anteriores)
    vec3 color_morado_rosado = vec3(0.45, 0.05, 0.40); 
    vec3 color_azul_morado = vec3(0.05, 0.12, 0.55);

    // 4. CONFIGURACIÓN DE COLORES PARA EL BORDE PROPIO (Celeste fosforescente y Rosado brillante)
    vec3 borde_celeste = vec3(0.0, 0.95, 1.0);
    vec3 borde_rosado = vec3(1.0, 0.2, 0.6);

    // 5. CALCULO DE LAS ONDAS DE FLUJO
    float ola = (uv.x * 2.5) + (uv.y * 1.5) + (TIME * velocidad_color);
    float factor_mezcla = (sin(ola) + 1.0) / 2.0;
    
    // Mezclas independientes
    vec3 color_relleno_final = mix(color_morado_rosado, color_azul_morado, factor_mezcla);
    vec3 color_borde_final = mix(borde_celeste, borde_rosado, factor_mezcla);

    // 6. RENDERIZADO FINAL CONDICIONAL
    vec3 color_final;
    if (es_borde) {
        // Si el píxel actual se identificó como borde de la letra, le metemos el celeste/rosado fosforescente
        color_final = color_borde_final * 2.0; // Multiplicado por 2.0 para que brille más que el centro
    } else {
        // Si es el centro de la letra, se queda con los tonos oscuros
        color_final = color_relleno_final * 1.2;
    }

    COLOR = vec4(color_final, max(tex_color.a, es_borde ? 1.0 : 0.0));
}