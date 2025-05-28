import subprocess
import os

def main():
    version = input("Enter the version tag (e.g. dev1, 2.1.0): ").strip()

    while True:
        side = input("Enter the side to export (c for client, s for server): ").strip().lower()
        if side in ('c', 's'):
            break
        print("Invalid option. Please enter 'c' or 's'.")

    side_name = "client" if side == "c" else "server"

    if side_name == "server":
        output_name = f"IR2-server-{version}.zip"
    else:
        output_name = f"IR2-{version}.zip"

    output_path = os.path.join(".", output_name)
    final_dest_dir = os.path.join(".", "out")
    final_dest = os.path.join(final_dest_dir, output_name)

    if not os.path.exists(final_dest_dir):
        os.makedirs(final_dest_dir)

    if os.path.exists(final_dest):
        overwrite = input(f"[WARN] File '{final_dest}' already exists. Overwrite? (Y/N): ").strip().lower()
        if overwrite != 'y':
            print("Operation cancelled.")
            return

    print(f"[BUILD] Exporting pack...\nVersion: {version}\nSide: {side_name}\nOutput: {output_name}")

    # Execute packwiz commands
    result = subprocess.run([
        "packwiz", "curseforge", "export",
        "-o", output_path,
        "-s", side_name
    ], capture_output=True, text=True)

    if result.returncode != 0:
        print(f"[ERROR] Export failed:\n{result.stderr}")
        return

    if not os.path.exists(output_path):
        print(f"[ERROR] Export did not produce the file: {output_path}")
        return

    # Move file to OUT
    try:
        os.replace(output_path, final_dest)
        print(f"[DONE] Export complete and moved to {final_dest}")
    except Exception as e:
        print(f"[ERROR] Failed to move file: {e}")

if __name__ == "__main__":
    main()
