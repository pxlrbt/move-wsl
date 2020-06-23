# Move WSL

Bash, batch and PowerShell script to move WSL 2 distros VHDX file to a different location.

![Interactive Example](screencast.gif)

## Usage

### Bash
Use with git bash for Windows or similiar.

#### Interactive way
1) `./move-wsl`
2) Select your distro
3) Enter your target (i.e. `/d/wsl target/ubuntu`)

#### Explicit way
1) Get a list of WSL distros: `wsl -l`
2) Move your image: `./move-wsl [NAME] [LOCATION]`

__Example:__ `./move-wsl docker-desktop /d/docker`


### PowerShell
Interactive way of moving wsl for Windows PowerShell.

1) `./move-wsl.ps1`
2) Select your distro
3) Enter your target (i.e. `D:\wsl target\ubuntu`)

### Batch
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

### 1.2.0 - 2020-06-23
Feat: Added PowerShell version by [sidecus](https://github.com/sidecus).

### 1.1.2 - 2020-06-22
Change: Use `-q` query for more parseble output of distros.

### 1.1.1 - 2020-05-29
Fix: (Default) appendix was breaking distro selection in interactive mode.

### 1.1 - 2020-04-14
Feat: Add interactive mode for bash script.

### 1.0 - 2020-04-13
Feat: Add validation for successfull export and import for bash and batch script.
