-- Set nautilus to dark theme
hl.on("hyprland.start", function()
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme \"prefer-dark\"")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("rivalcfg -c #ef66fa --strip-top-color #ef66fa --strip-middle-color #ef66fa --strip-bottom-color #ef66fa")
end)
