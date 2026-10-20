$ErrorActionPreference = 'Stop'
$dest = Join-Path $env:LOCALAPPDATA 'Cursors\Browser-Pointer-Rounded'
New-Item -ItemType Directory -Path $dest -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Cursors') -Destination $dest -Recurse -Force
$key='HKCU:\Control Panel\Cursors'
$map=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'mapping.json') -Raw | ConvertFrom-Json
$backup=Join-Path $dest 'previous-cursors.json'
if (!(Test-Path -LiteralPath $backup)) {
  $old=[ordered]@{}
  foreach($p in $map.PSObject.Properties){$old[$p.Name]=(Get-ItemPropertyValue -LiteralPath $key -Name $p.Name -ErrorAction SilentlyContinue)}
  $old | ConvertTo-Json | Set-Content -LiteralPath $backup -Encoding UTF8
}
foreach($p in $map.PSObject.Properties){
  Set-ItemProperty -LiteralPath $key -Name $p.Name -Value (Join-Path (Join-Path $dest 'Cursors') $p.Value)
}
Add-Type -TypeDefinition 'using System.Runtime.InteropServices; public class CursorRefresh { [DllImport("user32.dll", SetLastError=true)] public static extern bool SystemParametersInfo(uint action,uint param,System.IntPtr value,uint flags); }'
if (![CursorRefresh]::SystemParametersInfo(0x57,0,[IntPtr]::Zero,3)){throw 'Windows could not refresh the cursor scheme.'}
Write-Host 'Browser Pointer Rounded installed.'
