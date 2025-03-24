#!/bin/sh

# Get the current GTK3 theme
current_gtk3_theme=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")

# Get the current color scheme (for GTK4)
current_color_scheme=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")

# Set the GTK3 theme
gsettings set org.gnome.desktop.interface gtk-theme "$current_gtk3_theme"

# Set the GTK4 color scheme to prefer-dark
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

# Set QT theme (if needed)
export QT_QPA_PLATFORMTHEME=qt5ct
