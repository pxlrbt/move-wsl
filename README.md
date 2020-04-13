# Move WSL

Bash and batch script to move WSL 2 VHDX file to a different location

## Disclaimer
__Use at your own risk!__ I tested this on my machine and it worked fine. But be sure to have a backup of your machine.

## Usage

### Bash script
Use with git bash for Windows or similiar

1) Get a list of WSL images: `wsl -l`
2) Move your image: `./move-wsl [NAME] [LOCATION]`

__Example:__ `./move-wsl docker-desktop /d/docker`

### Batch script
Use from Windows CMD


1) Get a list of WSL images: `wsl -l`
2) Move your image: `move-wsl.bat [NAME] [LOCATION]`

__Example:__ `move-wsl.bat docker-desktop D:\docker`
