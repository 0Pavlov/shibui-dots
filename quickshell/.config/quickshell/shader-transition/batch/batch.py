import os
import re

"""
This script tries to batch-convert .glsl shaders
in the current directory to the format my transition setup supports.
It might be stupid, so don't try to rely on it for any possible .glsl shader
"""

def process_shader(code):
    # Find 'in' or 'varying' texcoord (WebGL 1 or 2)
    in_match = re.search(r'(?:in|varying)\s+vec2\s+(\w+);', code)
    in_var = in_match.group(1) if in_match else "v_texcoord"
    
    # Find 'out' fragColor
    out_match = re.search(r'out\s+vec4\s+(\w+);', code)
    out_var = out_match.group(1) if out_match else "gl_FragColor"

    # Extract Uniforms (handling comma-separated multiple variables on one line)
    uniform_pattern = re.compile(r'uniform\s+(?P<type>\w+)\s+(?P<names>[^;]+);')
    standard_uniforms = []
    samplers = []
    
    for match in uniform_pattern.finditer(code):
        utype = match.group('type')
        names_str = match.group('names')
        # Split by comma in case of "uniform float a, b;"
        names = [n.strip() for n in names_str.split(',')]
        
        for name in names:
            clean_name = name.split('[')[0].strip() # ignore array brackets for tracking
            if 'sampler' in utype:
                samplers.append((utype, clean_name))
            else:
                standard_uniforms.append((utype, clean_name))

    # Strip old boilerplate from code
    code = re.sub(r'#version .*?\n', '', code)
    code = re.sub(r'precision .*?;\n', '', code)
    code = re.sub(r'(?:in|varying)\s+vec2\s+\w+;\n?', '', code)
    code = re.sub(r'out\s+vec4\s+\w+;\n?', '', code)
    code = re.sub(r'uniform\s+.*?;[ \t]*\n?', '', code)
    code = re.sub(r'//\s*@duration.*\n', '', code)

    # Build the Qt UBO
    ubo_body = "    mat4 qt_Matrix;\n    float qt_Opacity;\n"
    for utype, name in standard_uniforms:
        ubo_body += f"    {utype} {name};\n"

    # Build the Sampler Bindings
    sampler_lines = ""
    old_sampler_name = "tex"
    if not samplers:
        # Default if none were found
        sampler_lines = "layout(binding = 1) uniform sampler2D sourceImage;\n"
    else:
        for idx, (utype, name) in enumerate(samplers):
            binding = idx + 1
            if idx == 0:
                old_sampler_name = name
                sampler_lines += f"layout(binding = {binding}) uniform {utype} sourceImage;\n"
            else:
                sampler_lines += f"layout(binding = {binding}) uniform {utype} {name};\n"

    # Construct the new header
    qt_header = f"""#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {{
{ubo_body}}} ubuf;

{sampler_lines}
"""

    # Safe Variable Replacement
    # (?<!\.) ensures we don't replace struct members like myObject.progress
    code = re.sub(rf'(?<!\.)\b{in_var}\b', 'qt_TexCoord0', code)
    code = re.sub(rf'(?<!\.)\b{out_var}\b', 'fragColor', code)
    code = re.sub(rf'(?<!\.)\b{old_sampler_name}\b', 'sourceImage', code)

    for utype, name in standard_uniforms:
        code = re.sub(rf'(?<!\.)\b{name}\b', f'ubuf.{name}', code)

    # The Smart Opacity Wrapper Trick
    # Rename original main to original_main, then create a new main that applies opacity
    code = re.sub(r'\bvoid\s+main\s*\(\s*\)', 'void qt_original_main()', code)
    
    code = qt_header + code.strip() + """

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
"""
    return code


def batch_convert():
    # Convert files from the current directory
    input_folder = "."
    # Store converted files in a separate folder
    output_folder = "converted_qt_shaders"

    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # Find all .glsl files in the current folder
    files = [f for f in os.listdir(input_folder) if f.endswith('.glsl')]

    if not files:
        print("No .glsl files found in the current directory.")
        return

    print(f"Found {len(files)} shader(s). Converting...")

    for filename in files:
        filepath = os.path.join(input_folder, filename)
        # Save as .frag files (my setup supports .frag shaders)
        out_filepath = os.path.join(output_folder, filename.replace('.glsl', '.frag'))

        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                original_code = f.read()

            converted_code = process_shader(original_code)

            with open(out_filepath, 'w', encoding='utf-8') as f:
                f.write(converted_code)
            
            print(f" [SUCCESS] Converted: {filename}")
        except Exception as e:
            print(f" [ERROR] Failed to convert {filename}: {e}")

    print(f"\nAll done! Check the '{output_folder}' folder.")

if __name__ == "__main__":
    batch_convert()
