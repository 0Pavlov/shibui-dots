import os
import subprocess
import sys

def change_theme(theme_name: str):
    # Construct a string for the image path based on the theme name
    path_background_img: str = f"~/.config/theme-switcher/background/{theme_name}.jpg"
    # Expanduser for it to work on any system
    path_background_img = os.path.expanduser(path_background_img)

    # Check if the image file actually exists before trying to apply it
    if not os.path.isfile(path_background_img):
        # Exit the program and notify the user
        exit(f"An error occurred: Background image not found at {path_background_img}.")

    # Try to apply the background theme
    try:
        # Execute awww to change the background instantly
        subprocess.run(
            ["awww", "img", path_background_img, "--transition-type", "none"],
            check=True,
            capture_output=True
        )
    except subprocess.CalledProcessError as apply_error:
        # Decode the standard error from the awww command
        error_msg = apply_error.stderr.decode().strip() if apply_error.stderr else str(apply_error)
        # Exit the program and notify the user
        exit(f"Failed to apply background: {error_msg}.")
    except Exception as general_error:
        # Exit the program and notify the user if awww is missing or another error occurs
        exit(f"An error occurred while executing awww: {general_error}.")

if __name__ == "__main__":
    # Just execute if called directly
    if len(sys.argv) > 1:
        change_theme(sys.argv[1])
