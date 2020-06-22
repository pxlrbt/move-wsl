Set-StrictMode -Version latest;

# function to get al distros
function Get-Distros()
{
    # wsl seems to output Unicode always. When parsing results in PowerShell it will try to convert
    # to Unicode strings (again) assuming it's in the Console.OutputEncoding code page (437 in my case).
    # This causes incorrect results. We are forcing Console.OutputEncoding to be Unicode here
    # to avoid the unnecessary conversion.
    $consoleEncoding = [Console]::OutputEncoding;
    [Console]::OutputEncoding = [System.Text.Encoding]::Unicode;
    $result = wsl -l -q;
    [Console]::OutputEncoding = $consoleEncoding;

    return $result;
}

# get all distros (skipping the first line "Windows Subsystem for Linux Distributions:")
Write-Host 'Getting distros...';
$distroList = Get-Distros;
if ($distroList.Length -le 0)
{
    Write-Error 'No distro found';
    Exit 1;
}

# get distro to move
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

# confirm
$confirm = Read-Host "Move $($distro) to $($targetFolder)? (Y|n)";
if ($confirm -ne 'Y')
{
    Write-Error 'User canceled';
    Exit 1;
}

# Create target dir if non existent
if (-Not(Test-Path $targetFolder))
{
    New-Item -Path $targetFolder -ItemType 'directory' | Out-Null;
    if (-not($?))
    {
        Write-Error "Failed to create target folder `"$($targetFolder)`"";
        Exit 1;
    }
}

# Export WSL image to tar file
$tempFile = Join-Path $targetFolder "$($distro).tar";
Write-Host "Exporting VHDX to `"$($tempFile)`" ...";
& cmd /c wsl --export $distro "`"$tempFile`"";
if (-not($? -and (Test-Path $tempFile -PathType Leaf)))
{
    Write-Error "ERROR: Export failed";
    Exit 2;
}

# Unregister WSL so we can register it again at new location
Write-Host "Unregistering WSL ..."
& cmd /c wsl --unregister $distro | Out-Null

# Importing WSL at new location
Write-Host "Importing $distro from $targetFolder..."
& cmd /c wsl --import $distro $targetFolder "`"$tempFile`"";

# Validating
$newDistroList = Get-Distros;
if ($newDistroList -notcontains $distro)
{
    Write-Error "Import failed. Distro not found. Export file at $tempFile";
    Exit 3;
}
if (-not(Test-Path "$($targetFolder)\ext4.vhdx"))
{
    Write-Error "ERROR: Import failed. Target file not found. Export file at $tempFile";
    Exit 4;
}

# Remove temporary file
Write-Host "Cleaning up ...";
Remove-Item $tempFile;

Write-Host "Done!" -ForegroundColor Green;
