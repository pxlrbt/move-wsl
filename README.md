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
