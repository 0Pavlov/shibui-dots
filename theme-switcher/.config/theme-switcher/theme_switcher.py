import sys
from hyprland import hyprland
from quickshell import quickshell
from ghostty import ghostty
from nvim import nvim

# Extract argv
argv: list = sys.argv

# Theme name
theme_name: str = argv[1]

# Check command-line args
if len(argv) != 2:
    exit('Command-line argument is expected. Maximum amount of arguments is 1.')

# Change hyprland theme
hyprland.change_theme(theme_name)
# Change quickshell theme
quickshell.change_theme(theme_name)
# Change ghostty theme
ghostty.change_theme(theme_name)
# Change nvim theme
nvim.change_theme(theme_name)
