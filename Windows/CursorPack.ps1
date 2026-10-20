function Test-CursorPack {
    param($Map, [string]$Source)
    $roles=@('Arrow','Help','AppStarting','Wait','Crosshair','IBeam','NWPen','No','SizeNS','SizeWE','SizeNWSE','SizeNESW','SizeAll','UpArrow','Hand')
    if (@($Map.PSObject.Properties).Count -ne $roles.Count) { throw 'The cursor manifest must contain 15 roles.' }
    foreach ($role in $roles) {
        $filename=$Map.$role
        if (!$filename -or $filename -notmatch '^[A-Za-z0-9-]+\.(cur|ani)$') { throw "Invalid cursor filename for $role." }
        if (!(Test-Path -LiteralPath (Join-Path $Source $filename) -PathType Leaf)) { throw "Missing cursor: $filename" }
    }
}
function Get-CursorSnapshot {
    param($Map,[string]$RegistryPath)
    $values=Get-ItemProperty -LiteralPath $RegistryPath
    $snapshot=[ordered]@{}
    foreach ($p in $Map.PSObject.Properties) { $snapshot[$p.Name]=$values.($p.Name) }
    return $snapshot
}
function Set-CursorSnapshot {
    param($Snapshot,[string]$RegistryPath)
    $names=if ($Snapshot -is [System.Collections.IDictionary]) { @($Snapshot.Keys) } else { @($Snapshot.PSObject.Properties.Name) }
    foreach ($name in $names) {
        $value=$Snapshot.$name
        if ($null -eq $value) { Remove-ItemProperty -LiteralPath $RegistryPath -Name $name -ErrorAction SilentlyContinue }
        else { Set-ItemProperty -LiteralPath $RegistryPath -Name $name -Value $value }
    }
}
function Update-SystemCursors {
    if (!('BrowserPointer.CursorRefresh' -as [type])) {
        Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; namespace BrowserPointer { public class CursorRefresh { [DllImport("user32.dll", EntryPoint="SystemParametersInfoW", SetLastError=true)] public static extern bool SystemParametersInfo(uint action,uint param,IntPtr value,uint flags); } }'
    }
    if (![BrowserPointer.CursorRefresh]::SystemParametersInfo(0x57,0,[IntPtr]::Zero,0)) { throw 'Windows could not refresh the cursor scheme.' }
}
