$ErrorActionPreference='Stop'
$pack=Join-Path $PSScriptRoot '..\Windows'
. (Join-Path $pack 'CursorPack.ps1')
$map=Get-Content -LiteralPath (Join-Path $pack 'mapping.json') -Raw | ConvertFrom-Json
Test-CursorPack -Map $map -Source (Join-Path $pack 'Cursors')
$bad=$map | ConvertTo-Json | ConvertFrom-Json
$bad.Arrow='..\Normal.cur'
$rejected=$false
try { Test-CursorPack -Map $bad -Source (Join-Path $pack 'Cursors') } catch { $rejected=$true }
if (!$rejected) { throw 'Invalid manifest was accepted.' }
$testKey='HKCU:\Software\BrowserPointerTests\'+[guid]::NewGuid().ToString('N')
New-Item -Path $testKey -Force | Out-Null
try {
    Set-ItemProperty -LiteralPath $testKey -Name Arrow -Value 'original-arrow.cur'
    Set-ItemProperty -LiteralPath $testKey -Name Hand -Value 'original-hand.cur'
    $old=Get-CursorSnapshot -Map $map -RegistryPath $testKey
    Set-ItemProperty -LiteralPath $testKey -Name Arrow -Value 'changed.cur'
    Set-ItemProperty -LiteralPath $testKey -Name Wait -Value 'new.ani'
    $roundTrip=$old | ConvertTo-Json | ConvertFrom-Json
    Set-CursorSnapshot -Snapshot $roundTrip -RegistryPath $testKey
    $restored=Get-CursorSnapshot -Map $map -RegistryPath $testKey
    if ($restored.Arrow -ne 'original-arrow.cur' -or $restored.Hand -ne 'original-hand.cur' -or $null -ne $restored.Wait) { throw 'Snapshot round trip failed.' }
    Set-CursorSnapshot -Snapshot $old -RegistryPath $testKey
} finally { Remove-Item -LiteralPath $testKey -Force }
& (Join-Path $pack 'Install.ps1') -WhatIf
Write-Output 'PASS: manifest, isolated registry backup/restore and install dry run. User cursor settings were not changed.'
