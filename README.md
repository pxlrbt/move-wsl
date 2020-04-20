# Move WSL

Bash and batch script to move WSL 2 distros VHDX file to a different location.

![Interactive Example](screencast.gif)

## Disclaimer
__Use at your own risk!__ I tested this on my machine and it worked fine. But be sure to have a backup of your machine.

## Usage

### Bash script
_This is the recommended version_. Use with git bash for Windows or similiar.

#### Interactive way
1) `./move-wsl`
2) Select your distro
3) Enter your target

#### Explicit way
1) Get a list of WSL distros: `wsl -l`
2) Move your image: `./move-wsl [NAME] [LOCATION]`

__Example:__ `./move-wsl docker-desktop /d/docker`

### Batch script
_This is a lightweight version_ which can also be used from Windows CMD.

1) Get a list of WSL distros: `wsl -l`
2) Move your image: `move-wsl.bat [NAME] [LOCATION]`

__Example:__ `move-wsl.bat docker-desktop D:\docker`

## FAQ

### Default user was switched to root when moving a distro

Set your default user inside your distro by adding this to your `/etc/wsl.conf`

```ini
[user]
default=YOUR_USERNAME
```

Then exit your distro, terminate it (`wsl -t YOUR_DISTRO`) and start it again.

### Standard distro switched when moving it distro

Since we need to unregister to import it with the same name, the standard distro can be switched. Just set your standard distro again:

```sh
wsl -s YOUR_DISTRO
```

## Changelog

### 1.1 - 2020-04-14
Feat: Add interactive mode for bash script.

### 1.0 - 2020-04-13
Feat: Add validation for successfull export and import for bash and batch script.
