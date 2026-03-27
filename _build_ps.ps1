# VoxCore Build Script — Use this instead of cmd.exe batch files from bash/Claude Code
# Usage: powershell.exe -ExecutionPolicy Bypass -File _build_ps.ps1 [preset] [target]
#   preset: "debug" (default), "rel", "relwithdebinfo"
#   target: "all" (default), "scripts", "configure" (configure-only, no build)
#
# Examples:
#   powershell.exe -ExecutionPolicy Bypass -File _build_ps.ps1
#   powershell.exe -ExecutionPolicy Bypass -File _build_ps.ps1 rel
#   powershell.exe -ExecutionPolicy Bypass -File _build_ps.ps1 debug scripts
#   powershell.exe -ExecutionPolicy Bypass -File _build_ps.ps1 rel configure

param(
    [string]$preset = "debug",
    [string]$target = "all"
)

# Map preset aliases
$presetMap = @{
    "debug" = "x64-Debug"
    "d" = "x64-Debug"
    "rel" = "x64-RelWithDebInfo"
    "r" = "x64-RelWithDebInfo"
    "relwithdebinfo" = "x64-RelWithDebInfo"
}

$cmakePreset = if ($presetMap.ContainsKey($preset.ToLower())) { $presetMap[$preset.ToLower()] } else { $preset }
$buildDir = "out/build/$cmakePreset"

# Import MSVC environment
$vsPath = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath 2>$null
if (-not $vsPath) {
    Write-Output "ERROR: Visual Studio not found"
    exit 1
}
$vcvars = Join-Path $vsPath "VC\Auxiliary\Build\vcvarsall.bat"
cmd /c "`"$vcvars`" x64 >NUL 2>&1 && set" | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') { [Environment]::SetEnvironmentVariable($matches[1], $matches[2]) }
}
Write-Output "VS: $vsPath"

Set-Location C:\Users\atayl\VoxCore

# Configure if needed (always reconfigure when target is "configure")
if ($target -eq "configure" -or -not (Test-Path "$buildDir/build.ninja")) {
    Write-Output "=== CMAKE CONFIGURE ($cmakePreset) ==="
    & cmake --preset $cmakePreset 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Output "CMAKE_CONFIGURE_FAILED"; exit 1 }
}

if ($target -eq "configure") {
    Write-Output "CONFIGURE_SUCCESS"
    exit 0
}

# Build
$buildArgs = @("--build", $buildDir, "-j", "32")
if ($target -eq "scripts") {
    $buildArgs += @("--target", "scripts")
    Write-Output "=== BUILD SCRIPTS ($cmakePreset) ==="
} else {
    Write-Output "=== BUILD ALL ($cmakePreset) ==="
}

& cmake @buildArgs 2>&1
if ($LASTEXITCODE -ne 0) { Write-Output "BUILD_FAILED"; exit 1 }

Write-Output "BUILD_SUCCESS"
