import os

def get_asset_map(directory):
    asset_map = {}
    for root, _, files in os.walk(directory):
        key = directory + '/' + root.replace('\\', '/').replace(directory, '').strip('/')
        file_list = [file for file in files]
        if file_list:
            asset_map[key] = file_list
    return asset_map

def write_dart_asset_file(asset_map, output_file):
    with open(output_file, 'w') as dart_file:
        dart_file.write("// Generated file. Do not modify manually.\n")
        dart_file.write("import 'dart:collection';\n\n")
        dart_file.write("final HashMap<String, List<String>> assets = HashMap<String, List<String>>.from({\n")

        for folder, files in asset_map.items():
            dart_file.write(f"  '{folder}': [\n")
            for file in files:
                dart_file.write(f"    '{file}',\n")
            dart_file.write("  ],\n")

        dart_file.write("});\n")

if __name__ == "__main__":
    # Configuration
    assets_dir = 'assets'  # Replace with your assets directory
    output_file = 'lib/src/assets_map.dart'  # Replace with the desired output path

    # Generate asset map
    asset_map = get_asset_map(assets_dir)

    # Write Dart file
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    write_dart_asset_file(asset_map, output_file)
    print(f"Asset list written to {output_file}")
