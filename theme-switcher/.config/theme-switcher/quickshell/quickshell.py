import os

def change_theme(theme_name: str):
    # Try to open quickshell theme specified in argv
    try:
        # Construct a string from argv
        path_quickshell_argv: str = f"~/.config/theme-switcher/quickshell/{theme_name}.qml"
        # Expanduser for it to work on any system
        path_quickshell_argv = os.path.expanduser(path_quickshell_argv)

        # Open the file with custom theme specified in argv
        with open(path_quickshell_argv, 'r') as file:
            custom_quickshell_theme: str = file.read()
    except Exception as read_error:
        # Exit the program and notify the user
        exit(f"An error occurred while opening the file: {read_error}.")


    # Path to the current quickshell theme
    path_quickshell = os.path.expanduser("~/.config/quickshell/Theme.qml")

    # Try to open the file
    try:
        with open(path_quickshell, "r") as file:
            # Store the current quickshell theme in a variable
            current_quickshell_theme: str = file.read()
    except Exception as read_error:
        # Exit the program and notify the user
        exit(f"An error occured while trying opening your current Quickshell theme: {read_error}")

    # Make a backup of the current theme
    current_quickshell_theme_backup: str = current_quickshell_theme

    # Try to apply the theme
    try:
        # Open the current quickshell theme
        with open(path_quickshell, "w") as file:
            # Apply the new quickshell theme
            file.write(custom_quickshell_theme)
    except Exception as write_error:
        # Restore the backup
        try:
            with open(path_quickshell, 'w') as file:
                file.write(current_quickshell_theme_backup)
        except Exception as restore_error:
            exit(f'Failed to restore a backup: {restore_error}. Your theme might be broken.')
        # Exit the program and notify the user
        print(f"Failed to write file: {write_error}")
