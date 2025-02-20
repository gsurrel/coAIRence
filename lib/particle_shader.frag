// Based on https://medium.com/dev-artel/shaders-in-flutter-1562fd33b994

// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;

out vec4 fragColor;

void main() {
    float t = uTime + 5.0;
    float z = 6.0;

    const int n = 100; // particle count

    vec3 startColor = vec3(176.0/255, 39.0/255, 156.0/255);
    vec3 endColor = vec3(0.06, 0.35, 0.85);

    float startRadius = 0.84;
    float endRadius = 1.6;

    float power = 0.51;
    float duration = 4.0;

    vec2 s = uSize;
    vec2 v = z * (2.0 * FlutterFragCoord().xy - s) / s.y;
    vec3 col = vec3(0.0);
    vec2 pm = v.yx * 2.8;

    float dMax = duration;
    float evo = (sin(uTime * 0.01 + 400.0) * 0.5 + 0.5) * 99.0 + 1.0;
    float mb = 0.0;
    float mbRadius = 0.0;
    float sum = 0.0;

    for (int i = 0; i < n; i++) {
        float d = fract(t * power + 48934.4238 * sin(float(i / int(evo)) * 692.7398));
        float a = 6.28 * float(i) / float(n);
        float x = d * cos(a) * duration;
        float y = d * sin(a) * duration;
        float distRatio = d / dMax;

        mbRadius = mix(startRadius, endRadius, distRatio);
        vec2 p = v - vec2(x, y);
        mb = mbRadius / dot(p, p);
        sum += mb;
        col = mix(col, mix(startColor, endColor, distRatio), mb / sum);
    }

    sum /= float(n);
    col = normalize(col) * sum;
    sum = clamp(sum, 0.0, 0.4);
    vec3 tex = vec3(1.0);
    col *= smoothstep(tex, vec3(0.0), vec3(sum));

    fragColor.rgb = col;
}
