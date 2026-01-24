import os
import sys
import glob
import subprocess
import tempfile

def reload_nvim():
    """
    Reloads NeoVim theme by finding active sockets and sending a remote command.
    Unlike Ghostty, Nvim needs a lua command sent via RPC, not a signal.
    """
    # Find the Runtime Directory (where sockets live)
    # usually /run/user/1000 or /tmp
    runtime_dir = os.environ.get("XDG_RUNTIME_DIR") or os.environ.get("TMPDIR") or "/tmp"

    # Find all sockets matching nvim.PID.0
    # This is the default naming convention for Nvim sockets
    sockets = glob.glob(os.path.join(runtime_dir, "nvim.*.0"))
    
    # Optional: Add specific named pipes if you use --listen
    # sockets += glob.glob(os.path.join(runtime_dir, "nvim-socket"))

    if not sockets:
        # No instances running, nothing to reload
        return

    # Construct the Lua command
    # We use dofile() to force execution even if previously loaded
    # We explicitly target current_theme.lua
    # We also try to refresh lualine if it exists
    lua_cmd = (
        "<Esc>:lua "
        "vim.cmd('hi clear'); "
        "if vim.fn.exists('syntax_on') then vim.cmd('syntax reset') end; "
        "dofile(vim.fn.stdpath('config') .. '/lua/current_theme.lua'); "
        "if package.loaded['lualine'] then require('lualine').refresh() end; "
        "vim.cmd('redraw!');"  # Force a UI redraw
        "<CR>"
    )

    for socket in sockets:
        try:
            # Send command to the socket using the nvim binary itself
            subprocess.run(
                ["nvim", "--server", socket, "--remote-send", lua_cmd],
                check=False,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
        except Exception as e:
            print(f"Failed to update instance at {socket}: {e}")


def change_theme(theme_name: str):
    # Ensure the input name handles the extension or not
    if not theme_name.endswith(".lua"):
        theme_name += ".lua"

    # Try to open the source theme file
    try:
        # Construct path: ~/.config/theme-switcher/nvim/shibui.lua
        source_path = os.path.expanduser(f"~/.config/theme-switcher/nvim/{theme_name}")
        
        with open(source_path, 'r') as file:
            new_theme_content: str = file.read()
    except Exception as read_error:
        exit(f"An error occurred while opening the source file ({source_path}): {read_error}.")

    # Path to the active nvim theme
    dest_path = os.path.expanduser("~/.config/nvim/lua/current_theme.lua")

    # Try to read current theme for backup
    current_theme_backup: str = ""
    try:
        # It's possible the destination file doesn't exist yet on fresh install
        if os.path.exists(dest_path):
            with open(dest_path, "r") as file:
                current_theme_backup = file.read()
    except Exception as read_error:
        exit(f"An error occured while reading current Nvim theme: {read_error}")

    # Try to apply the theme using Atomic Write
    try:
        # Create directory if it doesn't exist (e.g. fresh install)
        dir_name = os.path.dirname(dest_path)
        os.makedirs(dir_name, exist_ok=True)
        
        # Create a temp file in the SAME directory
        with tempfile.NamedTemporaryFile('w', delete=False, dir=dir_name) as tmp_file:
            tmp_file.write(new_theme_content)
            tmp_file.flush()
            os.fsync(tmp_file.fileno())
            tmp_path = tmp_file.name
        
        # Atomic replacement
        os.replace(tmp_path, dest_path)
        
        # Reload all running NeoVim instances
        reload_nvim()

    except Exception as write_error:
        # Restore the backup if we failed and had a backup
        if current_theme_backup:
            try:
                with open(dest_path, 'w') as file:
                    file.write(current_theme_backup)
            except Exception as restore_error:
                exit(f'Failed to restore backup: {restore_error}. Theme config might be broken.')
        
        print(f"Failed to write file: {write_error}")
