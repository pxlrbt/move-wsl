> [!Warning]
> As I switched the OS, I am not maintaining/updating this script anymore and there are some known issues (see the issue tab).

# Move WSL

PowerShell script to move WSL 1 and WSL 2 distros VHDX file to a different location.

![Interactive Example](screencast.gif)

## Usage

> **Warning**
> 
> This script uses official `wsl` commands and was used by a lot of people. Nevertheless some people had weird issues that resulted in broken WSL disks.
> Make sure you have a backup of your data, so you can restore in case of an error.

Interactive way of moving wsl for Windows PowerShell.

1) `./move-wsl.ps1`
2) Select your distro
3) Enter your target (i.e. `D:\wsl target\ubuntu`)

## Moving Docker WSL

Before moving Docker WSL make sure to stop the Docker service. Otherwise Docker will crash and you may need to reset it to factory defaults.

## FAQ

### Default user was switched to root when moving a distro

Set your default user inside your distro by adding the following configuration to your `/etc/wsl.conf`.

```ini
[user]
default=YOUR_USERNAME
```

If the file doesn't exist create it manually. Then exit your distro, terminate it (`wsl -t YOUR_DISTRO`) and start it again. For further options see [Microsoft Docs](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#user).

Some distributions also allow settings the default user via command line with `YOUR_DISTRO config --default-user YOUR_USER` (e.g. `ubuntu config --default-user johndoe`). Make sure to shutdown your distro before (`wsl -t YOUR_DISTRO`).

### Standard distro switched when moving it

Since we need to unregister to import it with the same name, the standard distro can be switched. Just set your standard distro again:

```sh
wsl -s YOUR_DISTRO
```

### WSL version was switched when moving distro

On import the distro will be registered with the current default WSL version. You can set your default WSL version with `wsl --set-default-version <Version>`.
When the WSL version was accidentally changed while moving, you can set the version with `wsl --set-version <Distro> <Version>`.
