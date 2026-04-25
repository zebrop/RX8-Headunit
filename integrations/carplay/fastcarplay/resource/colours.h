#ifndef SRC_RESOURCE_COLORS
#define SRC_RESOURCE_COLORS

#include <cstdint>

struct ColorRgba
{
    uint8_t r;
    uint8_t g;
    uint8_t b;
    uint8_t a;
};

inline constexpr ColorRgba color1_inactive{255, 255, 255, 80};
inline constexpr ColorRgba color2_inactive{255, 255, 255, 80};
inline constexpr ColorRgba color3_inactive{255, 255, 255, 80};
inline constexpr ColorRgba color4_inactive{255, 255, 255, 80};
inline constexpr ColorRgba color1{255, 87, 137, 255};
inline constexpr ColorRgba color2{135, 98, 255, 255};
inline constexpr ColorRgba color3{94, 228, 255, 255};
inline constexpr ColorRgba color4{93, 255, 197, 255};
inline constexpr ColorRgba colorError{255, 83, 64, 255};

#endif /* SRC_RESOURCE_COLORS */
