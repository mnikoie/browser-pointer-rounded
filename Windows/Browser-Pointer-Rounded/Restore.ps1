$ErrorActionPreference='Stop'
$backup=Join-Path $env:LOCALAPPDATA 'Cursors\Browser-Pointer-Rounded\previous-cursors.json'
if (!(Test-Path -LiteralPath $backup)){throw 'No saved cursor configuration found.'}
$old=Get-Content -LiteralPath $backup -Raw | ConvertFrom-Json
foreach($p in $old.PSObject.Properties){
  if($null -eq $p.Value){Remove-ItemProperty -LiteralPath 'HKCU:\Control Panel\Cursors' -Name $p.Name -ErrorAction SilentlyContinue}
  else{Set-ItemProperty -LiteralPath 'HKCU:\Control Panel\Cursors' -Name $p.Name -Value $p.Value}
}
Add-Type -TypeDefinition 'using System.Runtime.InteropServices; public class CursorRefresh { [DllImport("user32.dll", SetLastError=true)] public static extern bool SystemParametersInfo(uint action,uint param,System.IntPtr value,uint flags); }'
if (![CursorRefresh]::SystemParametersInfo(0x57,0,[IntPtr]::Zero,3)){throw 'Windows could not refresh the cursor scheme.'}
Write-Host 'Previous cursors restored.'
