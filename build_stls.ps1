# SPDX-License-Identifier: CC-BY-4.0
# Copyright (c) 2026 Bill Athing
#
# Rebuilds the STLs in stl\ and hinged-stls\ from the OpenSCAD sources, as listed in stl_parts.txt.
# Needs an OpenSCAD development snapshot ("nightly", 2024 or later) for the fast Manifold backend --
# the 2021.01 stable release doesn't have it and would take hours, if it finished at all.
#
#   .\build_stls.ps1                    build everything
#   .\build_stls.ps1 hinged-stls        build only one output folder
#   .\build_stls.ps1 main_top_left ...  build only these output file names (in every folder that has them)
#   .\build_stls.ps1 -Jobs 4            render at most 4 parts at once (default: the number of CPUs)
#
# Set $env:OPENSCAD to pick the binary. Easiest from Explorer / cmd: build_stls.cmd (same arguments).
[CmdletBinding(PositionalBinding = $false)]
param(
    [Parameter(ValueFromRemainingArguments = $true)] [string[]] $Only = @(),
    [int] $Jobs = [Environment]::ProcessorCount
)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

function Find-OpenSCAD {
    if ($env:OPENSCAD) { return $env:OPENSCAD }
    foreach ($c in @("$env:ProgramFiles\OpenSCAD (Nightly)\openscad.com",
                     "$env:ProgramFiles\OpenSCAD\openscad.com")) {
        if (Test-Path -LiteralPath $c) { return $c }
    }
    foreach ($c in @('openscad-nightly', 'openscad')) {
        $cmd = Get-Command $c -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
    }
    throw 'OpenSCAD not found -- install a nightly build or set $env:OPENSCAD to its openscad.com'
}
$openscad = Find-OpenSCAD
if (-not ((& $openscad --help 2>&1 | Out-String) -match '--backend')) {
    throw "$openscad has no Manifold backend -- this needs an OpenSCAD nightly / development snapshot"
}
Write-Host "Using $((& $openscad --version 2>&1 | Out-String).Trim()) ($openscad)"

# Parse stl_parts.txt: drop comments/blank lines, keep the lines whose folder or file name was asked for.
$parts = @()
foreach ($line in Get-Content -LiteralPath 'stl_parts.txt') {
    $f = @($line.Trim() -split '\s+')
    if ($f[0] -eq '' -or $f[0].StartsWith('#')) { continue }
    if ($Only.Count -gt 0 -and -not ($Only -contains $f[0] -or $Only -contains $f[1])) { continue }
    $parts += ,$f
}
if ($parts.Count -eq 0) { throw "nothing in stl_parts.txt matches: $($Only -join ' ')" }
Write-Host "Building $($parts.Count) STL(s), $Jobs at a time..."

# Each part renders to a temp file, which is moved into place only if OpenSCAD succeeds, so a failed render never
# leaves a broken STL behind. Arguments go to Start-Process as one pre-quoted string: Windows PowerShell 5.1 drops
# the inner quotes of -D part="..." when passing an argument array to a native program.
function Start-Part($f) {
    $dir, $name, $scad, $part = $f[0..3]
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $tmp = Join-Path $dir ".$name.tmp.stl"
    $argStr = "--backend=manifold -D `"part=\`"$part\`"`""
    foreach ($d in $f | Select-Object -Skip 4) { $argStr += " -D `"$d`"" }
    $argStr += " -o `"$tmp`" `"$scad`""
    $log = [IO.Path]::GetTempFileName()
    $p = Start-Process -FilePath $openscad -ArgumentList $argStr -NoNewWindow -PassThru `
                       -RedirectStandardError $log -RedirectStandardOutput "$log.out"
    $null = $p.Handle   # keep a handle open so ExitCode is still readable after the process exits
    return @{ Proc = $p; Dir = $dir; Name = $name; Tmp = $tmp; Log = $log }
}
function Finish-Part($j) {
    $j.Proc.WaitForExit()
    $out = "$($j.Dir)/$($j.Name).stl"
    if ($j.Proc.ExitCode -eq 0 -and (Test-Path -LiteralPath $j.Tmp)) {
        Move-Item -Force -LiteralPath $j.Tmp -Destination $out
        Write-Host "  ok    $out"
        $ok = $true
    } else {
        Remove-Item -Force -ErrorAction SilentlyContinue -LiteralPath $j.Tmp
        Write-Host "  FAIL  $out" -ForegroundColor Red
        Get-Content -LiteralPath $j.Log | ForEach-Object { Write-Host "        $_" }
        $ok = $false
    }
    Remove-Item -Force -ErrorAction SilentlyContinue -LiteralPath $j.Log, "$($j.Log).out"
    return $ok
}

$running = New-Object System.Collections.ArrayList
$failed = 0
foreach ($f in $parts) {
    while ($running.Count -ge $Jobs) {
        $done = @($running | Where-Object { $_.Proc.HasExited })
        if ($done.Count -eq 0) { Start-Sleep -Milliseconds 100; continue }
        foreach ($j in $done) { if (-not (Finish-Part $j)) { $failed++ }; $running.Remove($j) }
    }
    [void]$running.Add((Start-Part $f))
}
foreach ($j in $running) { if (-not (Finish-Part $j)) { $failed++ } }

if ($failed -gt 0) { Write-Host "$failed part(s) FAILED -- see above." -ForegroundColor Red; exit 1 }
Write-Host 'Done.'
