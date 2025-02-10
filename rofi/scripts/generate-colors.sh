#!/bin/sh

# Parse the Wallust colors file and convert rgb() format to hex
parse_rgb() {
    rgb=$(echo "$1" | grep -o 'rgb([^)]*)')
    if [ -n "$rgb" ]; then
        values=$(echo "$rgb" | sed 's/rgb(//' | sed 's/)//')
        echo "#$values"
    fi
}

# Read the Wallust config file and extract colors
WALLUST_CONFIG="$HOME/.config/hypr/wallust/wallust-hyprland.conf"

background=$(parse_rgb "$(grep 'background = ' "$WALLUST_CONFIG")")
foreground=$(parse_rgb "$(grep 'foreground = ' "$WALLUST_CONFIG")")

color0=$(parse_rgb "$(grep 'color0 = ' "$WALLUST_CONFIG")")
color1=$(parse_rgb "$(grep 'color1 = ' "$WALLUST_CONFIG")")
color2=$(parse_rgb "$(grep 'color2 = ' "$WALLUST_CONFIG")")
color3=$(parse_rgb "$(grep 'color3 = ' "$WALLUST_CONFIG")")
color4=$(parse_rgb "$(grep 'color4 = ' "$WALLUST_CONFIG")")
color5=$(parse_rgb "$(grep 'color5 = ' "$WALLUST_CONFIG")")
color6=$(parse_rgb "$(grep 'color6 = ' "$WALLUST_CONFIG")")
color7=$(parse_rgb "$(grep 'color7 = ' "$WALLUST_CONFIG")")
color8=$(parse_rgb "$(grep 'color8 = ' "$WALLUST_CONFIG")")
color9=$(parse_rgb "$(grep 'color9 = ' "$WALLUST_CONFIG")")
color10=$(parse_rgb "$(grep 'color10 = ' "$WALLUST_CONFIG")")
color11=$(parse_rgb "$(grep 'color11 = ' "$WALLUST_CONFIG")")
color12=$(parse_rgb "$(grep 'color12 = ' "$WALLUST_CONFIG")")
color13=$(parse_rgb "$(grep 'color13 = ' "$WALLUST_CONFIG")")
color14=$(parse_rgb "$(grep 'color14 = ' "$WALLUST_CONFIG")")
color15=$(parse_rgb "$(grep 'color15 = ' "$WALLUST_CONFIG")")

# Generate the Rofi colors file
cat > "$HOME/.config/rofi/themes/colors.rasi" << EOF
* {
    background: ${background};
    backgroundCC: ${background}CC;
    foreground: ${foreground};
    color0: ${color0};
    color1: ${color1};
    color2: ${color2};
    color3: ${color3};
    color4: ${color4};
    color5: ${color5};
    color6: ${color6};
    color7: ${color7};
    color8: ${color8};
    color9: ${color9};
    color10: ${color10};
    color11: ${color11};
    color12: ${color12};
    color13: ${color13};
    color14: ${color14};
    color15: ${color15};
}
EOF

