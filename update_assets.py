import os
import yaml
import shutil
def get_asset_files(directory):
    asset_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            asset_files.append(os.path.join(root, file).replace('\\', '/'))
    return asset_files

def update_pubspec(pubspec_path, assets):
    with open(pubspec_path, 'r') as file:
        data = yaml.safe_load(file)

    data['flutter']['assets'] = assets

    with open(pubspec_path, 'w') as file:
        yaml.dump(data, file, sort_keys=False)

if __name__ == "__main__":
    shutil.copy('pubspec.yaml', 'pubspec.yaml.bak')
    assets_dir = 'assets'  # Replace with your assets directory
    pubspec_file = 'pubspec.yaml'

    asset_files = get_asset_files(assets_dir)
    update_pubspec(pubspec_file, asset_files)
