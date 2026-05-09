shader_type spatial;

render_mode unshaded, blend_mix;

uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
float dot2(vec2 x) {
	return dot(x, x);
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5);
}
vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5);
}
vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}
float param_rndi(float minimum, float maximum, float seed) {
	return floor(param_rnd(minimum, maximum + 1.0, seed));
}
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
const float o2378656920546_s = 10.000000000;
const float p_o2378505925611_default_in1 = 0.000000000;
const float p_o2378505925611_default_in2 = 9.000000000;
const float p_o2378489148396_default_in1 = 0.000000000;
const float p_o2378489148396_default_in2 = 45.000000000;
const float p_o2378472371215_default_in1 = 0.000000000;
const float p_o2378472371215_default_in2 = 99.000000000;
const float p_o2378438816781_d_in1_z = 0.000000000;
const float p_o2378438816781_d_in2_x = 0.000000000;
const float p_o2378438816781_d_in2_y = 0.000000000;
const float p_o2378438816781_d_in2_z = 0.000000000;
const float p_o2378640143331_default_in1 = 2.000000000;
// #globals: math_3 (o2378505925611)
float pingpong(float a, float b)
{
  return (b != 0.0) ? abs(fract((a - b) / (b * 2.0)) * b * 2.0 - b) : 0.0;
}
// #globals: shader_1 (o2378455594000)
// #globals: sdf3d_rotate
vec3 rotate3d(vec3 p, vec3 a) {
	vec3 rv;
	float c;
	float s;
	c = cos(a.x);
	s = sin(a.x);
	rv.x = p.x;
	rv.y = p.y*c+p.z*s;
	rv.z = -p.y*s+p.z*c;
	c = cos(a.y);
	s = sin(a.y);
	p.x = rv.x*c+rv.z*s;
	p.y = rv.y;
	p.z = -rv.x*s+rv.z*c;
	c = cos(a.z);
	s = sin(a.z);
	rv.x = p.x*c+p.y*s;
	rv.y = -p.x*s+p.y*c;
	rv.z = p.z;
	return rv;
}
void fragment() {
	float _seed_variation_ = variation;
	vec4 _controlled_variation_ = vec4(0.0);
	vec2 uv = fract(UV);

// #code: math_4 (o2378640143331)
float o2378640143331_0_clamp_false = pow(p_o2378640143331_default_in1,(o2378656920546_s));
float o2378640143331_0_clamp_true = clamp(o2378640143331_0_clamp_false, 0.0, 1.0);
// #output0: math_4 (o2378640143331)
float o2378640143331_0_1_f = o2378640143331_0_clamp_false;

// #code: math_v3 (o2378438816781)
vec3 o2378438816781_0_clamp_false = vec3(((uv).x), ((uv).y), p_o2378438816781_d_in1_z)*vec3(o2378640143331_0_1_f);
vec3 o2378438816781_0_clamp_true = clamp(o2378438816781_0_clamp_false, vec3(0.0), vec3(1.0));
// #output0: math_v3 (o2378438816781)
vec3 o2378438816781_0_1_rgb = o2378438816781_0_clamp_false;

// #output1: decompose (o2378422039564)
float o2378422039564_1_1_f = vec4(o2378438816781_0_1_rgb, 1.0).g;

// #output0: decompose (o2378422039564)
float o2378422039564_0_2_f = vec4(o2378438816781_0_1_rgb, 1.0).r;

// #output0: shader_1 (o2378455594000)
float o2378455594000_0_1_f = float(int(o2378422039564_0_2_f)^int(o2378422039564_1_1_f));

// #code: math (o2378472371215)
float o2378472371215_0_clamp_false = mod(o2378455594000_0_1_f, p_o2378472371215_default_in2);
float o2378472371215_0_clamp_true = clamp(o2378472371215_0_clamp_false, 0.0, 1.0);
// #output0: math (o2378472371215)
float o2378472371215_0_1_f = o2378472371215_0_clamp_false;

// #code: math_2 (o2378489148396)
float o2378489148396_0_clamp_false = mod(o2378472371215_0_1_f, p_o2378489148396_default_in2);
float o2378489148396_0_clamp_true = clamp(o2378489148396_0_clamp_false, 0.0, 1.0);
// #output0: math_2 (o2378489148396)
float o2378489148396_0_1_f = o2378489148396_0_clamp_false;

// #code: math_3 (o2378505925611)
float o2378505925611_0_clamp_false = (1.0-step(p_o2378505925611_default_in2,o2378489148396_0_1_f));
float o2378505925611_0_clamp_true = clamp(o2378505925611_0_clamp_false, 0.0, 1.0);
// #output0: math_3 (o2378505925611)
float o2378505925611_0_1_f = o2378505925611_0_clamp_false;

	vec4 color_tex = vec4(vec3(o2378505925611_0_1_f), 1.0);
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	ALBEDO = color_tex.rgb;
	ALPHA = color_tex.a;
}



