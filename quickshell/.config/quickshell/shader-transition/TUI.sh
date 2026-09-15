#!/bin/bash

# Determine the target directory based on the optional argument
TARGET_DIR="./shaders"
if [ -n "$1" ]; then
    TARGET_DIR="./shaders/$1"
fi

# Store current working directory so we can always compile output to the script's folder
export OUT_DIR="$PWD"

# Move to the target directory to display and apply shaders
if ! cd "$TARGET_DIR" 2>/dev/null; then
    echo "Error: Directory $TARGET_DIR not found."
    exit 1
fi

# Check for .frag files to avoid errors
if ! ls *.frag 1> /dev/null 2>&1; then
    echo "Error: No .frag files found in $TARGET_DIR."
    exit 1
fi

# Create a temporary log file. 
# We will route all compiler output here so it displays on the right side of the screen.
export COMPILE_LOG=$(mktemp)
echo "Awaiting selection... Press ENTER to compile." > "$COMPILE_LOG"

# Create the function that compiles the shader.
# We export this function so fzf can trigger it internally.
compile_shader() {
    local shader="$1"
    
    # Write headers to log file
    echo "========================================" > "$COMPILE_LOG"
    echo "Compiling: $shader" >> "$COMPILE_LOG"
    echo "========================================" >> "$COMPILE_LOG"
    
    # Run the compiler and redirect both success and error output to the log file
    # OUT_DIR ensures it always compiles to the folder just outside of ./shaders
    if /usr/lib/qt6/bin/qsb --qt6 -b -o "$OUT_DIR/shader.frag.qsb" "$shader" >> "$COMPILE_LOG" 2>&1; then
        echo "" >> "$COMPILE_LOG"
        echo "SUCCESS: '$shader' is compiled and ACTIVE!" >> "$COMPILE_LOG"
    else
        echo "" >> "$COMPILE_LOG"
        echo "FAILED: Check the compiler errors above." >> "$COMPILE_LOG"
    fi
}
export -f compile_shader

# Run the UI
# - The UI stays perfectly still.
# - 'enter' runs compile function silently in the background and refreshes the preview.
ls -1 *.frag | fzf \
    --layout=reverse \
    --info=inline \
    --prompt="Search/Select > " \
    --header="[ENTER] Compile | [UP/DOWN] Browse | [ESC] Quit" \
    --preview="cat $COMPILE_LOG" \
    --preview-window="right:50%:wrap" \
    --bind "enter:execute-silent(bash -c 'compile_shader {}')+refresh-preview"

# Cleanup when you press ESC to exit
rm -f "$COMPILE_LOG"
clear
