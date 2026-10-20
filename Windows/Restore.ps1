[CmdletBinding(SupportsShouldProcess=$true)]
param()
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'CursorPack.ps1')
$backup=Join-Path $env:LOCALAPPDATA 'Cursors\Browser-Pointer-Rounded\previous-cursors.json'
if (!(Test-Path -LiteralPath $backup)) { throw 'No saved cursor configuration found.' }
$old=Get-Content -LiteralPath $backup -Raw | ConvertFrom-Json
$expected=@((Get-Content -LiteralPath (Join-Path $PSScriptRoot 'mapping.json') -Raw | ConvertFrom-Json).PSObject.Properties.Name)
$actual=@($old.PSObject.Properties.Name)
if (@(Compare-Object $expected $actual).Count) { throw 'The saved cursor configuration is incomplete or invalid.' }
if (!$PSCmdlet.ShouldProcess('Current user cursor settings','Restore the previous cursors')) { return }
Set-CursorSnapshot -Snapshot $old -RegistryPath 'HKCU:\Control Panel\Cursors'
Update-SystemCursors
Write-Host 'Previous cursors restored.'
