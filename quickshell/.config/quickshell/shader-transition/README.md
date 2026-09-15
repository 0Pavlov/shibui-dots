# Quickshell Transition.qml Module

This is a custom theme transition module that supports shader transitions for the WHOLE desktop.

<p width="100%">
  <video src="https://github.com/user-attachments/assets/0bcbcdfd-0b78-4393-9827-1100c1349c43"></video>
</p>

Essentially, this module does the following:
1. Takes screenshots of all of your monitors with `grim`.
2. Displays them as a separate Quickshell window in fullscreen.
3. Runs an arbitrary script (this might be your theme-switcher, wallpaper setter, or whatever changes the look of your system).
4. Removes the "before" screenshots from your screen using `.frag` shaders for the opacity change.
5. Closes the shell.

It is designed to be called by another `.qml` module and accepts an argument (e.g., the name of the theme). 
The caller should be doing something like this:

```qml
function applyTheme() {
    // Hide the OSD instantly so we get a clean screenshot of the desktop
    root.revealed = false
    
    const tTheme = themeModel.get(root.selectedIndex).name
    
    // Launch Transition.qml completely detached
    orchestrator.command = [
        "bash", "-c", 
        "TARGET_THEME='" + tTheme + "' quickshell -p ~/.config/quickshell/shader-transition/Transition.qml > /tmp/transition.log 2>&1 & disown"
    ]
    
    orchestrator.running = true
}
```

### Limitations
1. You cannot do anything while the transition is happening, nor does it capture motion on the "unrevealed" side.
2. If the shader duration is long, it might look weird, especially when you are watching a video or if some motion is actively happening on the screen.

### PROS AND WHY I DID THIS:
1. Most rices have cool transitions for their wallpapers (when using swww/awww), but NOT THE SHELL. The shell usually just restarts, and it looks stupid to me.
2. I am okay with the transition freezing my screen (the coolness of how it looks outweighs this drawback), and anyway, I am not planning to change themes like crazy every minute.
3. Built with tools you probably already have on your system: `grim` and `quickshell`. No plugins.
4. I will work on it so delays become smaller, and with a fast shader (0.5 - 1 second duration), the transition is almost instant.
5. SHADERS! FUN! COOL!

---

### Side-by-Side Comparison

| How it is usually done | The way I want it to look |
|------------------------|---------------------------|
| <video src="[Placeholder: video_clip_here_todo]"></video> | <video src="https://github.com/user-attachments/assets/65ff698d-1849-4d50-8fa8-801705ad7605"></video> |

---

**Shout-out / Credits:**
Most of the shaders I took and converted are from [jbuck95/Hyprland-Shader](https://github.com/jbuck95/Hyprland-Shader), who took most of their shaders from [liixini/shaders](https://github.com/liixini/shaders) :)

---

#### Installation
1. Clone the `shader-transition` dir to your quickshell directory. 

First, change the `DEST` path below to match your quickshell dir, then paste this into your terminal (it will download only the `shader-transition` dir there, not the whole repo):

```bash
DEST="$HOME/path_to_your_quickshell_dir"

git clone --depth 1 --filter=blob:none --sparse https://github.com/0Pavlov/shibui-dots.git _tmp \
  && git -C _tmp sparse-checkout set quickshell/.config/quickshell/shader-transition \
  && mkdir -p "$DEST" \
  && cp -r _tmp/quickshell/.config/quickshell/shader-transition "$DEST/" \
  && rm -rf _tmp
```

2. Call your wallpaper/theme-switcher/custom-script from `Transition.qml` (so it can change something 'behind the scenes').

3. Tie your quickshell OSD theme `picker` to `Transition.qml`, so it calls it after you pick a theme.

Or just call `Transition.qml` with `quickshell -p Transition.qml` at the 'right moment' when changing a theme.

---

### `shader.frag.qsb` is the currently compiled/baked shader in use.
- It must have this exact name, since it is referenced directly inside the `Transition.qml` file.

**Do not forget to bake the shader every time you update or modify it if you are not using a script:**
```bash
/usr/lib/qt6/bin/qsb --qt6 -b -o shader.frag.qsb shader_name.frag
```

---

### To apply a shader
```bash
./shaders/apply_shader.sh name_of_the_shader
```
Or (if you prefer the TUI, keep in mind that you need `fzf` installed on your system to use it):
```bash
./TUI.sh
```

Also, `./TUI.sh`, located in the `shader-transition` directory, can accept an argument, which is the name of a subdirectory inside of `./shaders/`.
This allows you to have a `fav` dir or any possible grouping for your shaders. 
For example, there are already some shaders that are favorites for me:
```bash
./TUI.sh fav
```
This will allow you to browse shaders in the `shaders/fav` dir and apply them from there. The same applies for your custom directories in `./shaders/name_of_the_dir`.

- It will compile the shader and replace the `shader.frag.qsb` file that is located next to the `Transition.qml` file.
- When using these scripts, there is no need to compile, move, or rename shader files manually.

---

### Batch conversion of `.glsl` shaders found online
- Put your shaders in the `./batch` directory.
- Run `python batch.py` and it will try to convert the shaders.
- It will put the converted shaders into the `./converted_qt_shaders` directory.
- You need to take those and put them into the main `/shaders` directory.
- Apply them the exact same way using the `apply_shader.sh` script or the TUI.

---

### The duration of the whole transition is determined inside the `Transition.qml` file (not in the shader itself)
So take a look at the code inside if you need to adjust it.

---

### TODOS:
- Maybe add support for the caller to be able to send an `osd has done its thing and now is closed` signal to `Transition.qml` so it knows for sure when to start.
