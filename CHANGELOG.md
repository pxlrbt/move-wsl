# Changelog

## 1.3.2 - 2020-09-09
Fix: Bug in PS script: Import failed when target folder was entered with trailing slash.

## 1.3.1 - 2020-08-09
Fix: Bug in Batch script not validating export properly when using a path with spaces.

## 1.3.0 - 2020-07-16
Feat: WSL1 support.

## 1.2.2 - 2020-07-16
Fix: Error in PowerShell script when only one distro is installed Better error handling of export by [manie204](https://github.com/manie204).

## 1.2.1 - 2020-07-07
Feat: Better error handling of export by [Schop0](https://github.com/Schop0). \
Fix: Replace newlines in wsl command output as it broke selection sometimes.

## 1.2.0 - 2020-06-23
Feat: Added PowerShell version by [sidecus](https://github.com/sidecus).

## 1.1.2 - 2020-06-22
Change: Use `-q` query for more parseble output of distros.

## 1.1.1 - 2020-05-29
Fix: (Default) appendix was breaking distro selection in interactive mode.

## 1.1 - 2020-04-14
Feat: Add interactive mode for bash script.

## 1.0 - 2020-04-13
Feat: Add validation for successfull export and import for bash and batch script.
