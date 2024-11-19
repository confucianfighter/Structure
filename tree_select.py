import os
import pyperclip
import sys
from InquirerPy import inquirer
from prompt_toolkit import prompt
# Define the extensions to include (source code and config files)
ALLOWED_EXTENSIONS = {".dart",".py", ".js", ".html", ".css", ".json", ".yaml", ".yml", ".xml", ".toml", ".ini", ".sh", ".bat"}

def generate_tree_menu(path):
    """
    Generate a tree menu for the given directory path, including only
    source code and configuration files.
    """
    choices = []
    for root, dirs, files in os.walk(path):
        # Add folder to the choices
        relative_root = os.path.relpath(root, path)
        if relative_root == ".":
            relative_root = os.path.basename(path)
        choices.append({"name": relative_root, "value": {"type": "folder", "path": root}})
        
        # Add files under the folder, filtering by allowed extensions
        for file in files:
            if os.path.splitext(file)[1] in ALLOWED_EXTENSIONS:
                file_path = os.path.join(root, file)
                choices.append({"name": f"  {file}", "value": {"type": "file", "path": file_path}})
    return choices

def build_file_contents_string(selected_files):
    """
    Build a string with file paths and their source code, including line numbers.
    """
    builder = []
    for file_path in sorted(selected_files):
        try:
            builder.append(f"File: {file_path}\n{'=' * 80}\n")
            with open(file_path, "r") as file:
                for line_num, line in enumerate(file, start=1):
                    builder.append(f"{line_num:4}: {line}")
            builder.append("\n\n")
        except Exception as e:
            builder.append(f"Error reading file {file_path}: {e}\n\n")
    return ''.join(builder)

def main():
    # get the first argument as the relative path
    path = sys.argv[1]

    choices = generate_tree_menu(path)

    # Show the multi-select tree menu
    selected = inquirer.checkbox(
        message="Select folders/files:",
        choices=choices,
        instruction="(Folders auto-select their contents)"
    ).execute()

    # Process the selection
    final_selection = set()
    for item in selected:
        if item["type"] == "folder":
            # Include files directly in the selected folder
            for root, _, files in os.walk(item["path"]):
                if root == item["path"]:  # Only process the selected folder itself
                    for file in files:
                        if os.path.splitext(file)[1] in ALLOWED_EXTENSIONS:
                            final_selection.add(os.path.join(root, file))
        else:
            # Include explicitly selected file
            final_selection.add(item["path"])
    
    # Build the string
    output_string = ""
    output_string = output_string + "\n" + build_file_contents_string(final_selection)
    
    if input("Do you want to preview before copying to clipboard? (y/n): ").lower() == "y":
        print("\nGenerated File Contents:")
        print(output_string)
        if input("\nCopy to clipboard? (y/n): ").lower() == "y":
            pyperclip.copy(output_string)
            print("\nContents copied to clipboard.")
    else:
        pyperclip.copy(output_string)
        print("\nGenerated File Contents:")
    
if __name__ == "__main__":
    main()
