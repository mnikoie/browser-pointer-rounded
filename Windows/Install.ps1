[CmdletBinding(SupportsShouldProcess=$true)]
param()
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'CursorPack.ps1')
$dest=Join-Path $env:LOCALAPPDATA 'Cursors\Browser-Pointer-Rounded'
$key='HKCU:\Control Panel\Cursors'
$map=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'mapping.json') -Raw | ConvertFrom-Json
$source=Join-Path $PSScriptRoot 'Cursors'
Test-CursorPack -Map $map -Source $source
if (!$PSCmdlet.ShouldProcess('Current user cursor settings','Install Browser Pointer Rounded')) { return }
New-Item -ItemType Directory -Path $dest -Force | Out-Null
$targetCursors=Join-Path $dest 'Cursors'
New-Item -ItemType Directory -Path $targetCursors -Force | Out-Null
foreach ($p in $map.PSObject.Properties) {
    Copy-Item -LiteralPath (Join-Path $source $p.Value) -Destination (Join-Path $targetCursors $p.Value) -Force
}
$backup=Join-Path $dest 'previous-cursors.json'
$old=Get-CursorSnapshot -Map $map -RegistryPath $key
$installedArrow=Join-Path $targetCursors $map.Arrow
# Preserve the pre-install backup on updates, refresh it after a theme switch.
if (!(Test-Path -LiteralPath $backup) -or $old.Arrow -ne $installedArrow) {
    $temporary=Join-Path $dest 'previous-cursors.tmp'
    $old | ConvertTo-Json | Set-Content -LiteralPath $temporary -Encoding UTF8
    Move-Item -LiteralPath $temporary -Destination $backup -Force
}
try {
    foreach ($p in $map.PSObject.Properties) {
        Set-ItemProperty -LiteralPath $key -Name $p.Name -Value (Join-Path $targetCursors $p.Value)
    }
    Update-SystemCursors
} catch {
    Set-CursorSnapshot -Snapshot $old -RegistryPath $key
    Update-SystemCursors
    throw
}
Write-Host 'Browser Pointer Rounded installed. Run Restore.cmd to undo.'
