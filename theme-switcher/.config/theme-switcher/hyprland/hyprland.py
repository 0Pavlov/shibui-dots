import os

def change_theme(theme_name: str):
    # Try to open hyprland theme specified in argv
    try:
        # Construct a string from argv
        path_hyprland_argv: str = f"~/.config/theme-switcher/hyprland/{theme_name}.conf"
        # Expanduser for it to work on any system
        path_hyprland_argv = os.path.expanduser(path_hyprland_argv)

        # Open the file with custom theme specified in argv
        with open(path_hyprland_argv, 'r') as file:
            custom_hyprland_theme: str = file.read()
    except Exception as read_error:
        # Exit the program and notify the user
        exit(f"An error occurred while opening the file: {read_error}.")


    # Path to the current hyprland theme
    path_hyprland = os.path.expanduser("~/.config/hypr/hyprland/colors.conf")

    # Try to open the file
    try:
        with open(path_hyprland, "r") as file:
            # Store the current hyprland theme in a variable
            current_hyprland_theme: str = file.read()
    except Exception as read_error:
        # Exit the program and notify the user
        exit(f"An error occured while trying opening your current Hyprland theme: {read_error}")

    # Make a backup of the current theme
    current_hyprland_theme_backup: str = current_hyprland_theme

    # Try to apply the theme
    try:
        # Open the current hyprland theme
        with open(path_hyprland, "w") as file:
            # Apply the new hyprland theme
            file.write(custom_hyprland_theme)
    except Exception as write_error:
        # Restore the backup
        try:
            with open(path_hyprland, 'w') as file:
                file.write(current_hyprland_theme_backup)
        except Exception as restore_error:
            exit(f'Failed to restore a backup: {restore_error}. Your theme might be broken.')
        # Exit the program and notify the user
        print(f"Failed to write file: {write_error}")
