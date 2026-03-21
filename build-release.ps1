param(
    [string]$Version = "2.0.5",
    [string]$OutputDirectory
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$addonRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$addonName = Split-Path -Leaf $addonRoot

if (-not $OutputDirectory -or $OutputDirectory.Trim() -eq "") {
    $OutputDirectory = Split-Path -Parent $addonRoot
}

if (-not (Test-Path -LiteralPath $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory | Out-Null
}

$zipPath = Join-Path $OutputDirectory ("{0}-{1}.zip" -f $addonName, $Version)
if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}

$stagingDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString("N"))
$stagingAddonDir = Join-Path $stagingDir $addonName

try {
    New-Item -ItemType Directory -Path $stagingAddonDir -Force | Out-Null

    Get-ChildItem -LiteralPath $addonRoot -Force | Where-Object {
        $_.Name -ne ".release-staging" -and
        $_.Name -ne "issues" -and
        $_.Name -ne "CURSEFORGE_DESCRIPTION.md" -and
        $_.Name -ne ".gitattributes" -and
        $_.Name -ne ".git" -and
        $_.Name -ne ".vscode" -and
        $_.Name -ne "build-release.ps1"
    } | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $stagingAddonDir -Recurse -Force
    }

    [System.IO.Compression.ZipFile]::CreateFromDirectory(
        $stagingDir,
        $zipPath,
        [System.IO.Compression.CompressionLevel]::Optimal,
        $false
    )

    if (-not (Test-Path -LiteralPath $zipPath)) {
        throw ("Release package was not created: {0}" -f $zipPath)
    }

    $archiveInfo = Get-Item -LiteralPath $zipPath
    if ($archiveInfo.Length -le 0) {
        throw ("Release package is empty: {0}" -f $zipPath)
    }

    Write-Host ("Release package created: {0}" -f $zipPath)
    Write-Host ("Release package size: {0} bytes" -f $archiveInfo.Length)
}
finally {
    if (Test-Path -LiteralPath $stagingDir) {
        Remove-Item -LiteralPath $stagingDir -Recurse -Force
    }
}
