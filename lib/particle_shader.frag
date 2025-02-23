// Shader mostly by Xor (https://www.shadertoy.com/view/l3cfW4)

// Licence https://creativecommons.org/licenses/by-nc-sa/3.0/deed.en
// Attribution-NonCommercial-ShareAlike 3.0 Unported

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;

out vec4 fragColor;

void main() {
    vec2 r = uSize;
    vec2 p = (FlutterFragCoord().xy * 2 - r) / r.y * mat2(4, -3, 3, 4);
    float t = uTime;
    float T = t + 0.1 * p.x;

    vec4 O = vec4(0.0);
    vec4 baseColor = vec4(0.5, 0.0, 0.5, 1.0);
    vec4 colorMod = vec4(1.0, 2.0, 3.0, 0.0);

    for (int i = 0; i < 45; i++) {
        float iFloat = float(i);
        
        vec4 color = baseColor
            * (cos(sin(iFloat) * colorMod) + 1.0)
            * exp(sin(iFloat + 0.1 * iFloat * T))
            / length(max(p, p / vec2(3.0, 8.0)));
                
        O += color;
        p += 2.0 * cos(iFloat * vec2(11.0, 9.0) + iFloat * iFloat + T * 0.2);
    }

    O = tanh(0.01 * p.y * vec4(0.0, 1.0, 2.0, 3.0) + O * O / 1e4);
    fragColor = O;
}
