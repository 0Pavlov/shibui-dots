import os
import signal
import sys
import tempfile

def reload_ghostty():
    """
    Reloads Ghostty by reading /proc directly.
    Filters out 'ghostty +boo' or other client commands to prevent crashing them.
    """
    try:
        # Get all numeric PIDs
        pids = [pid for pid in os.listdir('/proc') if pid.isdigit()]
    except Exception as e:
        print(f"Error reading /proc: {e}")
        return

    for pid in pids:
        try:
            pid_path = os.path.join('/proc', pid)
            
            # Check process name (comm)
            with open(os.path.join(pid_path, 'comm'), 'rb') as f:
                name = f.read().decode().strip()
            
            if name != "ghostty":
                continue

            # Check command line args (cmdline) to distinguish Window vs +boo
            # cmdline args are separated by null bytes (\x00)
            with open(os.path.join(pid_path, 'cmdline'), 'rb') as f:
                cmdline_raw = f.read().decode(errors='ignore')
                cmd_args = cmdline_raw.split('\x00')

            # If the process is running a specific mode like +boo, DO NOT signal it
            # We only want to signal the main terminal window, not the client tools
            if any(arg.startswith('+') for arg in cmd_args):
                continue

            # If we passed checks, signal the process
            os.kill(int(pid), signal.SIGUSR2)

        except (ProcessLookupError, PermissionError, FileNotFoundError):
            continue


def change_theme(theme_name: str):
    # Try to open ghostty theme specified in argv
    try:
        # Construct a string from argv
        path_ghostty_argv: str = f"~/.config/theme-switcher/ghostty/{theme_name}"
        # Expanduser for it to work on any system
        path_ghostty_argv = os.path.expanduser(path_ghostty_argv)

        # Open the file with custom theme specified in argv
        with open(path_ghostty_argv, 'r') as file:
            custom_ghostty_theme: str = file.read()
    except Exception as read_error:
        # Exit the program and notify the user
        exit(f"An error occurred while opening the file: {read_error}.")


    # Path to the current ghostty theme
    path_ghostty = os.path.expanduser("~/.config/ghostty/theme-config")

    # Try to open the file
    try:
        with open(path_ghostty, "r") as file:
            # Store the current ghostty theme in a variable
            current_ghostty_theme: str = file.read()
    except Exception as read_error:
        # Exit the program and notify the user
        exit(f"An error occured while trying opening your current Ghostty theme: {read_error}")

    # Make a backup of the current theme
    current_ghostty_theme_backup: str = current_ghostty_theme

    # Try to apply the theme using Atomic Write
    try:
        # Create a temp file in the SAME directory (required for atomic move)
        dir_name = os.path.dirname(path_ghostty)
        
        with tempfile.NamedTemporaryFile('w', delete=False, dir=dir_name) as tmp_file:
            tmp_file.write(custom_ghostty_theme)
            # Ensure data is physically on disk
            tmp_file.flush()
            os.fsync(tmp_file.fileno())
            tmp_path = tmp_file.name
        
        # Atomic replacement: Swaps files instantly
        os.replace(tmp_path, path_ghostty)
        
        # Reload ghostty
        reload_ghostty()

    except Exception as write_error:
        # Restore the backup
        try:
            with open(path_ghostty, 'w') as file:
                file.write(current_ghostty_theme_backup)
        except Exception as restore_error:
            exit(f'Failed to restore a backup: {restore_error}. Your theme might be broken.')
        # Exit the program and notify the user
        print(f"Failed to write file: {write_error}")
