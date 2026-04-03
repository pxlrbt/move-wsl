# ============================================================================
# Move-WSL v1.4.0
# PowerShell script to move WSL 1 and WSL 2 distros VHDX file to a different location.
# Fixes: #37, #30, #35, #29, #23
# ============================================================================

param(
    [string]$Distro,
    [string]$Target,
    [switch]$Force,
    [switch]$NoShutdown
)

Set-StrictMode -Version latest;

function Cleanup() {
    # Remove temporary file
    Write-Host "Cleaning up ..." -ForegroundColor Gray;
    Remove-Item -ErrorAction Ignore $tempFile;
}

# Fixed Get-Distros function - now works
function Get-Distros() {
    $env:WSL_UTF8 = 1
    
    $wslOutput = wsl -l -v 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        return @()
    }
    
    $lines = ($wslOutput -replace "`0", "") -split "`r?`n" | Where-Object { $_.Trim() -ne "" } | Select-Object -Skip 1
    
    $result = @()
    foreach ($line in $lines) {
        $cleanLine = $line -replace '^\s*', ''
        if ([string]::IsNullOrWhiteSpace($cleanLine)) { continue }
        
        $isDefault = $cleanLine.StartsWith('*')
        if ($isDefault) {
            $cleanLine = $cleanLine.Substring(1).TrimStart()
        }
        
        $parts = @($cleanLine -split '\s+' | Where-Object { $_ -ne "" })
        
        if ($parts.Count -ge 3) {
            $result += [PSCustomObject]@{
                SELECTED = if ($isDefault) { '*' } else { '' }
                NAME     = $parts[0]
                STATE    = $parts[1]
                VERSION  = $parts[2]
            }
        }
    }
    
    return $result
}

# Function to check if folder has NTFS compression (Fix #23)
function Test-FolderCompressed {
    param([string]$Path)
    
    # Check parent folder if target doesn't exist yet
    $checkPath = $Path
    while (-not (Test-Path $checkPath) -and $checkPath.Length -gt 3) {
        $checkPath = Split-Path $checkPath -Parent
    }
    
    if (Test-Path $checkPath) {
        try {
            $attributes = (Get-Item $checkPath -Force).Attributes
            return ($attributes -band [System.IO.FileAttributes]::Compressed) -ne 0
        }
        catch {
            return $false
        }
    }
    return $false
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

Write-Host "=== Move-WSL v1.4.0 ===" -ForegroundColor Cyan
Write-Host "Move your WSL distros to a new location" -ForegroundColor Gray

# Get and make sure there are distros
Write-Host 'Getting distros...' -ForegroundColor Gray;
$distros = @(Get-Distros);

if ($distros.Count -eq 0) {
    Write-Error 'No WSL distro found. Make sure WSL is installed and you have at least one distro.';
    Exit 1;
}

$distroList = @($distros | ForEach-Object { $_.NAME });

# Interactive mode if no parameters
if ([string]::IsNullOrEmpty($Distro)) {
    Write-Host "Select distro to move:" -ForegroundColor Yellow;
    $id = 0;
    $distros | ForEach-Object { 
        $defaultMark = if ($_.SELECTED -eq '*') { " (default)" } else { "" }
        Write-Host "  $($id+1): $($_.NAME)$defaultMark [WSL$($_.VERSION), $($_.STATE)]" -ForegroundColor White
        $id++
    }
    
    $selected = [int](Read-Host "Enter number");
    if (($selected -gt $distroList.Length) -or ($selected -le 0)) {
        Write-Error "Invalid selection. Select a distro from 1 to $($distroList.Length)";
        Exit 1;
    }
    $distro = $distroList[$selected - 1];
    $selectedIndex = $selected - 1;
}
else {
    if ($distroList -notcontains $Distro) {
        Write-Error "Distro '$Distro' not found. Available: $($distroList -join ', ')";
        Exit 1;
    }
    $distro = $Distro;
    $selectedIndex = [array]::IndexOf($distroList, $distro);
}

# Check if this distro is the default (Fix #29)
$isDefault = $distros[$selectedIndex].SELECTED -eq '*'
if ($isDefault) {
    Write-Host "Note: '$distro' is your default WSL distro. This will be preserved." -ForegroundColor Cyan
}

# Get target directory
if ([string]::IsNullOrEmpty($Target)) {
    Write-Host "Enter target directory:" -ForegroundColor Yellow;
    $targetFolder = Read-Host;
}
else {
    $targetFolder = $Target;
}

# Validate target folder
if ($targetFolder.Length -le 3 -and $targetFolder.EndsWith(':\')) {
    Write-Error 'Target folder cannot be root of a drive (e.g., D:\). Use a subfolder.';
    Exit 1;
}

$targetFolder = $targetFolder.TrimEnd('\');

# Check for NTFS compression (Fix #23)
if (Test-FolderCompressed $targetFolder) {
    Write-Host ""
    Write-Warning "Target folder has NTFS compression enabled!"
    Write-Host "  This can corrupt WSL images and cause data loss." -ForegroundColor Red
    Write-Host "  To disable: Right-click folder > Properties > Advanced > Uncheck 'Compress contents'" -ForegroundColor Yellow
    
    if (-not $Force) {
        Write-Error "Operation aborted. Use -Force to override (not recommended).";
        Exit 1;
    }
    Write-Host "  Proceeding anyway due to -Force flag..." -ForegroundColor Yellow
}

# Confirm
if (-not $Force) {
    $confirm = Read-Host "Move '$distro' to "$targetFolder"? (Y/n)";
    if ($confirm -ne 'Y' -and $confirm -ne 'y' -and $confirm -ne '') {
        Write-Host 'Operation cancelled by user.' -ForegroundColor Yellow;
        Exit 0;
    }
}

# Create target dir if non existent
if (-not(Test-Path $targetFolder)) {
    Write-Host "Creating target folder..." -ForegroundColor Gray
    New-Item -Path $targetFolder -ItemType 'directory' | Out-Null;
    if (-not($?)) {
        Write-Error "Failed to create target folder "$targetFolder"";
        Exit 1;
    }
}
elseif (Test-Path ( -join ($targetFolder, "\ext4.vhdx"))) {
    Write-Error "Target folder already contains an ext4.vhdx file that will get overwritten. Aborting.";
    Exit 1;
}

# Shutdown WSL to release file locks (Fix #30 and #35)
if (-not $NoShutdown) {
    Write-Host "nShutting down WSL to release file locks..." -ForegroundColor Yellow
    wsl --shutdown 2>&1 | Out-Null
    Start-Sleep -Seconds 2
    Write-Host "  WSL shutdown complete." -ForegroundColor Green
}

# Export WSL image to tar file
$tempFile = Join-Path $targetFolder "$($distro).tar";
Write-Host "Exporting '$distro' to "$tempFile"..." -ForegroundColor Yellow;
Write-Host "  This may take several minutes depending on distro size..." -ForegroundColor Gray

& cmd /c wsl --export $distro ""$tempFile"";
if (-not($? -and (Test-Path $tempFile -PathType Leaf))) {
    Write-Error "Export failed. Check if the distro is healthy with 'wsl -l -v'";
    Cleanup;
    Exit 2;
}

$tarSize = [math]::Round((Get-Item $tempFile).Length / 1MB, 2)
Write-Host "  Export complete! ($tarSize MB)" -ForegroundColor Green

# Unregister WSL so we can register it again at new location
Write-Host "Unregistering old location..." -ForegroundColor Yellow
& cmd /c wsl --unregister $distro | Out-Null

# Importing WSL at new location
Write-Host "Importing '$distro' to new location..." -ForegroundColor Yellow
& cmd /c wsl --import $distro $targetFolder ""$tempFile"" --version $distros[$selectedIndex].VERSION;

# Validating
Write-Host "Validating import..." -ForegroundColor Gray
$newDistros = @(Get-Distros);
$newDistroList = @($newDistros | ForEach-Object { $_.NAME });

if ($newDistroList -notcontains $distro) {
    Write-Error "Import failed! Distro not found after import. Export file preserved at: $tempFile";
    Exit 3;
}

if (-not(Test-Path "$($targetFolder)\ext4.vhdx") -And -not(Test-Path "$($targetFolder)\rootfs")) {
    Write-Error "Import failed! Target file/folder not found. Export file preserved at: $tempFile";
    Exit 4;
}

# Restore default distro if it was default (Fix #29)
if ($isDefault) {
    Write-Host "Restoring default distro setting..." -ForegroundColor Gray
    wsl --set-default $distro 2>&1 | Out-Null
}

Cleanup;

Write-Host "Done! '$distro' has been moved to '$targetFolder'" -ForegroundColor Green;

if ($isDefault) {
    Write-Host "Default distro setting preserved." -ForegroundColor Green
}

Write-Host "Tip: If your default user changed to root, add this to /etc/wsl.conf:" -ForegroundColor Gray
Write-Host "  [user]" -ForegroundColor Gray
Write-Host "  default=YOUR_USERNAMEn" -ForegroundColor Gray