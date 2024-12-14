import os

class AssetNode:
    def __init__(self, name, parent=None):
        self.name = name
        self.parent = parent
        self.children = {}

    def add_child(self, child_name):
        sanitized_name = self._sanitize_name(child_name)
        if sanitized_name not in self.children:
            self.children[sanitized_name] = AssetNode(sanitized_name, self)
        return self.children[sanitized_name]

    @staticmethod
    def _sanitize_name(name):
        sanitized = name.replace('.', '_dot_').replace('-', '_').replace(' ', '_')
        if sanitized.isdigit() or sanitized in {"class", "static", "final", "const"}:
            sanitized = f'_{sanitized}'
        return sanitized

    @property
    def full_path(self):
        parts = []
        current = self
        while current:
            parts.append(current.name)
            current = current.parent
        return '/'.join(reversed(parts)).strip('/')

    def to_dart_class(self, class_name="Assets", indent=0):
        if not self.children:  # Avoid generating empty classes
            return ""
        indent_str = ' ' * 2 * indent
        lines = [f'{indent_str}class {class_name} {{']

        for name, node in self.children.items():
            if node.children:  # It's a folder
                child_class_name = name
                lines.append(f'{indent_str}  static final {child_class_name} = {child_class_name}();')
            else:  # It's a file
                lines.append(f'{indent_str}  static const String {name} = "{node.full_path}";')

        for name, node in self.children.items():
            if node.children:
                child_class_name = name
                child_class_code = node.to_dart_class(class_name=child_class_name, indent=indent + 1)
                if child_class_code:  # Avoid adding empty child classes
                    lines.append(child_class_code)

        lines.append(f'{indent_str}}};')
        return '\n'.join(lines)

def build_asset_tree(base_path):
    root = AssetNode('')
    for dirpath, dirnames, filenames in os.walk(base_path):
        relative_path = os.path.relpath(dirpath, base_path)
        parts = relative_path.split(os.sep) if relative_path != '.' else []

        current_node = root
        for part in parts:
            current_node = current_node.add_child(part)

        for filename in filenames:
            current_node.add_child(filename)

    return root

def generate_flutter_asset_code(base_path, output_file):
    tree = build_asset_tree(base_path)
    dart_code = tree.to_dart_class()

    if not dart_code.strip():  # Handle the case of an empty tree
        print("The assets folder is empty or no valid assets were found.")
    else:
        with open(output_file, 'w') as file:
            file.write(dart_code)
            print(dart_code)

# Example usage
assets_folder = "assets"
output_dart_file = "assets.dart"
generate_flutter_asset_code(assets_folder, output_dart_file)
