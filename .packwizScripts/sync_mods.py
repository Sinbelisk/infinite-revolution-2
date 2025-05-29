import os
import shutil
import zipfile
from pathlib import Path
import subprocess

CONFIG_FILE = "sync_conf.cfg"
MOD_FOLDER = Path("mods")
BACKUP_DIR = Path("backup")

def read_or_prompt_origin():
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, "r") as f:
            origin_base = f.read().strip()
    else:
        print("[SETUP] No saved profile base path found.")
        origin_base = input("Please enter the base path to your ATLauncher profile folder (e.g. C:\\Users\\YourName\\AppData\\Roaming\\ATLauncher\\instances\\YourProfile): ").strip()
        with open(CONFIG_FILE, "w") as f:
            f.write(origin_base)
        print(f"[SETUP] Path saved to {CONFIG_FILE}.")
    return Path(origin_base) / "mods"

def confirm_continue():
    print("[INFO] This script will sync the mods from the IR2 ATLauncher profile.")
    print("[INFO][WARN] The original mods folder will be deleted and replaced.")
    confirm = input("Do you want to continue? (Y/N): ").strip().lower()
    return confirm == 'y'

def backup_mods():
    if MOD_FOLDER.exists():
        BACKUP_DIR.mkdir(exist_ok=True)

        base_backup = BACKUP_DIR / "mods_old.zip"
        if not base_backup.exists():
            print(f"[BACKUP] Backing up existing mods folder to '{base_backup}'...")
            zip_folder(MOD_FOLDER, base_backup)
        else:
            count = 1
            while True:
                numbered_backup = BACKUP_DIR / f"mods_old_{count}.zip"
                if not numbered_backup.exists():
                    print(f"[BACKUP] Backing up existing mods folder to '{numbered_backup}'...")
                    zip_folder(MOD_FOLDER, numbered_backup)
                    break
                count += 1

        shutil.rmtree(MOD_FOLDER)

def zip_folder(folder_path: Path, output_zip: Path):
    with zipfile.ZipFile(output_zip, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(folder_path):
            for file in files:
                file_path = Path(root) / file
                zipf.write(file_path, file_path.relative_to(folder_path.parent))

def copy_mods(origin: Path):
    print(f"[COPY] Copying folder from '{origin}' to '{MOD_FOLDER}'...")
    shutil.copytree(origin, MOD_FOLDER, dirs_exist_ok=True)
    print("[COPY] Copy complete.")

def run_packwiz():
    print("[PACKWIZ] [SYNC] Syncing mods...")
    subprocess.run(["packwiz", "curseforge", "detect"], check=False)
    print("[PACKWIZ] [FINISHING] Refreshing index...")
    subprocess.run(["packwiz", "refresh"], check=False)

def main():
    origin = read_or_prompt_origin()
    print(f"[INFO] Full source mods folder path: {origin}")

    if not confirm_continue():
        print("Operation cancelled.")
        return

    backup_mods()
    copy_mods(origin)
    run_packwiz()
    input("Press Enter to exit...")

if __name__ == "__main__":
    main()
