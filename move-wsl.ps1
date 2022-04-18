Set-StrictMode -Version latest;

function Cleanup()
{
    # Remove temporary file
    Write-Host "Cleaning up ...";
    Remove-Item -ErrorAction Ignore $tempFile;
}

# function to get distros
function Get-Distros()
{
    # wsl seems to output Unicode always. When parsing results in PowerShell it will try to convert
    # to Unicode strings (again) assuming it's in the Console.OutputEncoding code page (437 in my case).
    # This causes incorrect results. We are forcing Console.OutputEncoding to be Unicode here
    # to avoid the unnecessary conversion.
    $consoleEncoding = [Console]::OutputEncoding;
    [Console]::OutputEncoding = [System.Text.Encoding]::Unicode;
    $result = wsl -l -v | ConvertFrom-String -PropertyNames SELECTED, NAME, STATE, VERSION | Select-Object -Skip 1;
    [Console]::OutputEncoding = $consoleEncoding;

    return $result;
}

# get and make sure there are distros
Write-Host 'Getting distros...';
$distros = @(Get-Distros);
$distroList = $distros | ForEach-Object { $_.NAME };
if ($distroList.Length -le 0)
{
    Write-Error 'No distro found';
    Exit 1;
}

# prompt and get the distro to move
Write-Host "Select distro to move:";
$id = 0;
$distroList | ForEach-Object { Write-Host "$($id+1): $($distroList[$id])" -ForegroundColor Yellow; $id++; }
$selected = [int](Read-Host);
if (($selected -gt $distroList.Length) -or ($selected -le 0))
{
    Write-Error "Invalid selection. Select a distro from 1 to $($distroList.Length)";
    Exit 1;
}
$distro = $distroList[$selected - 1];

# get target directory
Write-Host 'Enter WSL target directory:';
$targetFolder = Read-Host;

# check if the target folder is the root of a drive
if ($targetFolder.Length -le 3 -and $targetFolder.EndsWith(':\'))
{
    Write-Error 'Target folder cannot be root of a drive';
    Exit 1;
}

$targetFolder = $targetFolder.trimend('\');

# confirm
$confirm = Read-Host "Move $($distro) to `"$($targetFolder)`"? (Y|n)";
if ($confirm -ne 'Y')
{
    Write-Error 'User canceled';
    Exit 1;
}

# Create target dir if non existent
if (-not(Test-Path $targetFolder))
{
    New-Item -Path $targetFolder -ItemType 'directory' | Out-Null;
    if (-not($?))
    {
        Write-Error "Failed to create target folder `"$($targetFolder)`"";
        Exit 1;
    }
} elseif (Test-Path (-join($targetFolder, "\ext4.vhdx")))
{
    Write-Error "Target folder already contains an ext4.vhdx file that will get overwritten. Aborting.";
    Exit 1;
}

# Export WSL image to tar file
$tempFile = Join-Path $targetFolder "$($distro).tar";
Write-Host "Exporting VHDX to `"$($tempFile)`" ...";
& cmd /c wsl --export $distro "`"$tempFile`"";
if (-not($? -and (Test-Path $tempFile -PathType Leaf)))
{
    Write-Error "ERROR: Export failed";
    Cleanup;
    Exit 2;
}

# Unregister WSL so we can register it again at new location
Write-Host "Unregistering WSL ..."
& cmd /c wsl --unregister $distro | Out-Null

# Importing WSL at new location
Write-Host "Importing $distro from $targetFolder..."
& cmd /c wsl --import $distro $targetFolder "`"$tempFile`"" --version $distros[$selected -1].VERSION;

# Validating
$newDistros = @(Get-Distros);
$newDistroList = $newDistros | ForEach-Object { $_.NAME };
if ($newDistroList -notcontains $distro)
{
    Write-Error "Import failed. Distro not found. Export file at $tempFile";
    Exit 3;
}

if (-not(Test-Path "$($targetFolder)\ext4.vhdx") -And -not(Test-Path "$($targetFolder)\rootfs"))
{
    Write-Error "ERROR: Import failed. Target file/folder not found. Export file at $tempFile";
    Exit 4;
}

Cleanup;

Write-Host "Done!" -ForegroundColor Green;
