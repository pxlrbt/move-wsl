# Move WSL

PowerShell script to move WSL 1 and WSL 2 distros VHDX file to a different location.

![Interactive Example](screencast.gif)

## Features (v1.4.0)

- ✅ Supports both WSL 1 and WSL 2
- ✅ Interactive and CLI modes
- ✅ Automatic WSL shutdown to prevent file locks
- ✅ Preserves default distro setting
- ✅ Pre-checks for NTFS compression (prevents corruption)
- ✅ Colored output with progress feedback

## Usage

### Interactive Mode

```powershell
./move-wsl.ps1
```

1. Select your distro from the list
2. Enter your target path (e.g., `D:\wsl\ubuntu`)
3. Confirm the operation

### CLI Mode (Non-Interactive)

```powershell
# Basic usage
./move-wsl.ps1 -Distro "Ubuntu" -Target "D:\wsl\ubuntu"

# Force mode (skip confirmations)
./move-wsl.ps1 -Distro "Ubuntu" -Target "D:\wsl\ubuntu" -Force

# Skip WSL shutdown (not recommended)
./move-wsl.ps1 -Distro "Ubuntu" -Target "D:\wsl\ubuntu" -NoShutdown
```

### Parameters

| Parameter | Description |
|-----------|-------------|
| `-Distro` | Name of the WSL distro to move |
| `-Target` | Destination folder path |
| `-Force` | Skip confirmation prompts and NTFS compression warning |
| `-NoShutdown` | Skip automatic WSL shutdown (not recommended) |

## ⚠️ Important Notes

> **Warning**
> 
> This script uses official `wsl` commands and was used by many people. Make sure you have a backup of your data before proceeding.

### Before Running

1. **Backup important data** in your WSL distro
2. **Close all applications** using WSL
3. **Stop Docker Desktop** if moving Docker WSL distros

### NTFS Compression Warning

The script will check if the target folder has NTFS compression enabled. **Compressed folders can corrupt WSL images.** If detected, disable compression:

1. Right-click the target folder
2. Properties → Advanced
3. Uncheck "Compress contents to save disk space"

## FAQ

### Default user was switched to root when moving a distro

Set your default user inside your distro by adding the following configuration to your `/etc/wsl.conf`:

```ini
[user]
default=YOUR_USERNAME
```

If the file doesn't exist, create it manually. Then exit your distro, terminate it (`wsl -t YOUR_DISTRO`) and start it again.

Some distributions also allow setting the default user via command line:
```powershell
ubuntu config --default-user johndoe
```

### Standard distro switched when moving it

The script now automatically preserves the default distro setting (v1.4.0+). If using an older version:

```powershell
wsl -s YOUR_DISTRO
```

### Script cannot be loaded (not digitally signed)

Run this command to allow the script:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
./move-wsl.ps1
```

### WSL version was switched when moving distro

On import, the distro will be registered with its original WSL version. If it changed:

```powershell
wsl --set-version <Distro> <Version>
```

## Moving Docker WSL

Before moving Docker WSL, make sure to:

1. Stop Docker Desktop completely
2. Wait a few seconds for processes to terminate
3. Run the script

## License

This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE) file for details.
