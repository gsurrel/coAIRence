#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;

out vec4 fragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - 0.5 * uSize) / uSize.y;

    float ang = radians(36.87);
    float ca = cos(ang), sa = sin(ang);
    mat2 rot = mat2(ca, -sa, sa, ca);
    vec2 p = rot * uv * 5.0;

    float t_warp  = uTime + 0.1 * p.x;
    float t_pulse = uTime;

    vec4 col = vec4(0.0);
    vec4 baseColor  = vec4(0.4, 0.02, 0.45, 1.0);
    vec4 spectralMod = vec4(2.0, 4.0, 2.2, 0.0);

    const int ITER = 15;
    for (int n = 0; n < ITER; n++) {
        float i = float(n);
        float pulse_t = t_pulse + i * 0.3;

        vec4 spectralShift = (cos(sin(i)) * spectralMod + 1.0) * baseColor;
        float pulse = exp(sin(i + 0.1 * i * pulse_t));

        vec2 falloffVec = max(p, p / vec2(3.0, 8.0));
        float dist = length(falloffVec);
        if (n == 0) dist = max(dist, 0.15);

        col += (spectralShift * pulse) / dist;

        vec2 angle = vec2(i * 11.0, i * 9.0) + i * i + t_warp * 0.2;
        p += 2.0 * cos(angle);
    }

    vec3 compressed = (col.rgb * col.rgb) / 10000.0;
    vec3 mapped = compressed / (1.0 + compressed);

    float raw_mag = length(col.rgb);
    float warmth = clamp((raw_mag - 80.0) / 120.0, 0.0, 1.0);

    mapped.r += warmth * 0.45;
    mapped.g += warmth * 0.20;
    mapped.b -= warmth * 0.45;
    mapped = clamp(mapped, 0.0, 1.0);

    vec3 bg = vec3(0.03, 0.003, 0.06);
    fragColor = vec4(bg + mapped * (1.0 - bg), 1.0);
}