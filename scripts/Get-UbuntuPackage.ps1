#!/usr/bin/env pwsh
# Downloads and extracts Ubuntu .deb packages for cross-compilation.
# Queries packages.ubuntu.com to automatically resolve latest package versions,
# eliminating hardcoded package filenames that break when Ubuntu updates packages.

param(
    [Parameter(Mandatory=$true)]
    [string]$PackageName,
    
    [Parameter(Mandatory=$true)]
    [string]$Release,
    
    [Parameter(Mandatory=$false)]
    [string]$Architecture = "arm64",
    
    [Parameter(Mandatory=$false)]
    [string]$ExtractPath = "."
)

# Map release numbers to codenames
$ReleaseCodenames = @{
    "22.04" = "jammy"
    "24.04" = "noble"
    "20.04" = "focal"
    "24.10" = "oracular"
}

# Resolve release to codename
$Codename = if ($ReleaseCodenames.ContainsKey($Release)) {
    $ReleaseCodenames[$Release]
} else {
    $Release  # Assume it's already a codename
}

Write-Host "Resolving package: $PackageName for Ubuntu $Codename ($Architecture)" -ForegroundColor Cyan

# Construct packages.ubuntu.com URL
$PackageUrl = "https://packages.ubuntu.com/$Codename/$Architecture/$PackageName/download"

try {
    # Fetch the download page with retry logic
    Write-Host "Fetching package info from $PackageUrl..." -ForegroundColor Gray
    $MaxRetries = 3
    $RetryDelay = 2
    $Response = $null
    
    for ($i = 1; $i -le $MaxRetries; $i++) {
        try {
            $Response = Invoke-WebRequest -Uri $PackageUrl -UseBasicParsing -ErrorAction Stop
            break
        } catch {
            if ($i -eq $MaxRetries) { throw }
            Write-Host "Retry $i/$MaxRetries after $RetryDelay seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds $RetryDelay
            $RetryDelay *= 2
        }
    }
    
    # Parse HTML to find package filename and path
    # The page shows: "You can download the requested file from the pool/main/x/xyz/ subdirectory"
    # And later: "More information on xyz_version_arch.deb:"
    
    if ($Response.Content -match 'pool/main/([^/]+)/([^/]+)/') {
        $PoolPath = "pool/main/$($Matches[1])/$($Matches[2])"
    } else {
        Write-Error "Could not find pool path for $PackageName"
        exit 1
    }
    
    if ($Response.Content -match "More information on <kbd>([^<]+\.deb)</kbd>") {
        $DebFileName = $Matches[1]
    } else {
        Write-Error "Could not find .deb filename for $PackageName"
        exit 1
    }
    
    # Construct download URL (use ports.ubuntu.com for arm64, archive.ubuntu.com for amd64)
    $Mirror = if ($Architecture -eq "arm64") { "ports.ubuntu.com" } else { "archive.ubuntu.com" }
    $DebUrl = "http://$Mirror/$PoolPath/$DebFileName"
    
    Write-Host "Found package: $DebFileName" -ForegroundColor Green
    Write-Host "Download URL: $DebUrl" -ForegroundColor Gray
    
    # Create working directory
    $WorkDir = Join-Path $ExtractPath "$PackageName-$Architecture"
    if (Test-Path $WorkDir) {
        Remove-Item -Recurse -Force $WorkDir
    }
    New-Item -ItemType Directory -Path $WorkDir | Out-Null
    Push-Location $WorkDir
    
    try {
        # Download the .deb file
        Write-Host "Downloading $DebFileName..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $DebUrl -OutFile $DebFileName -UseBasicParsing
        
        # Extract the .deb archive
        Write-Host "Extracting package..." -ForegroundColor Cyan
        
        # Extract ar archive
        & ar -x $DebFileName
        
        # Find and extract data archive (could be .tar.zst, .tar.xz, or .tar.gz)
        $DataArchive = Get-ChildItem -Filter "data.tar.*" | Select-Object -First 1
        
        if (-not $DataArchive) {
            Write-Error "Could not find data archive in $DebFileName"
            exit 1
        }
        
        Write-Host "Extracting $($DataArchive.Name)..." -ForegroundColor Gray
        
        if ($DataArchive.Name -match '\.zst$') {
            # Try zstd -d first, fall back to unzstd
            $ZstdCmd = if (Get-Command zstd -ErrorAction SilentlyContinue) { "zstd -d" } else { "unzstd" }
            & tar --use-compress-program="$ZstdCmd" -xf $DataArchive.Name
        } elseif ($DataArchive.Name -match '\.xz$') {
            & tar -xf $DataArchive.Name
        } elseif ($DataArchive.Name -match '\.gz$') {
            & tar -xzf $DataArchive.Name
        } else {
            Write-Error "Unknown compression format: $($DataArchive.Name)"
            exit 1
        }
        
        Write-Host "✓ Successfully extracted $PackageName to $WorkDir" -ForegroundColor Green
        
        # Return the working directory path
        $WorkDir
        
    } finally {
        Pop-Location
    }
    
} catch {
    Write-Error "Failed to download/extract package: $_"
    exit 1
}
