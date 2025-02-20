// Based on https://medium.com/dev-artel/shaders-in-flutter-1562fd33b994

// Shader mostly by Xor (https://www.shadertoy.com/view/l3cfW4)

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;

out vec4 fragColor;

void main() {
    vec2 r = uSize;
    vec2 p = (FlutterFragCoord().xy + FlutterFragCoord().xy - r) / r.y * mat2(4, -3, 3, 4);
    float t = uTime;
    float T = t + 0.1 * p.x;

    vec4 O = vec4(0.0);
    for (int i = 0; i < 50; i++) {
        float iFloat = float(i);
        
        vec4 color = (cos(sin(iFloat) * vec4(1.0, 2.0, 3.0, 0.0)) + 1.0)
            * exp(sin(iFloat + 0.1 * iFloat * T))
            / length(max(p, p / vec2(1.0, 2.0)));
        
        O += color;
        p += 2.0 * cos(iFloat * vec2(11.0, 9.0) + iFloat * iFloat + T * 0.2);
    }

    O = tanh(0.01 * p.y * vec4(0.0, 1.0, 2.0, 3.0) + O * O / 1e4);
    fragColor = O;
}
