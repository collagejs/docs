#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Checks all Markdown files in src/routes for broken internal links.

.DESCRIPTION
    Collects every HREF value from all primary-sidebar.json files found under
    src/routes and uses them as the set of known-good internal paths.

    Then it scans every Markdown (.md) file under src/routes and verifies that
    each absolute internal link (one whose href starts with "/") refers to a path
    present in that set.  Both HTML anchor elements and Markdown-style links are
    checked.  External links (http/https) and fragment-only links (#anchor) are
    skipped.

    On error the script writes one line per broken link containing the file path,
    line number and the offending href, then exits with code 1.

    When -Fix is supplied and the CI environment variable is not "true" the script
    additionally attempts to replace each broken href with the closest known-good
    href matched by its last path segment.

.PARAMETER Fix
    Attempt to auto-fix broken links.  Ignored when running inside CI/CD
    (i.e. when the CI environment variable equals "true").

.PARAMETER RootDir
    Root directory of the repository.  Defaults to the parent directory of the
    folder that contains this script.

.EXAMPLE
    # Check only
    pwsh scripts/check-links.ps1

.EXAMPLE
    # Check and auto-fix (only outside CI/CD)
    pwsh scripts/check-links.ps1 -Fix
#>
param(
    [switch]$Fix,
    [string]$RootDir = (Join-Path $PSScriptRoot '..')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RootDir  = [System.IO.Path]::GetFullPath($RootDir)
$isCI     = $env:CI -eq 'true'
$shouldFix = $Fix.IsPresent -and -not $isCI

$routesDir = Join-Path $RootDir 'src' 'routes'

if (-not (Test-Path $routesDir -PathType Container)) {
    Write-Error "src/routes directory not found at: $routesDir"
    exit 1
}

# ── 1. Collect valid HREFs from all primary-sidebar.json files ─────────────────

$validHrefs = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::Ordinal
)

function Collect-Hrefs ([object[]]$Items) {
    foreach ($item in $Items) {
        $hrefProp     = $item.PSObject.Properties['href']
        $articlesProp = $item.PSObject.Properties['articles']
        if ($null -ne $hrefProp -and $null -ne $hrefProp.Value -and $hrefProp.Value -ne '') {
            $null = $validHrefs.Add([string]$hrefProp.Value)
        }
        if ($null -ne $articlesProp -and $null -ne $articlesProp.Value) {
            Collect-Hrefs $articlesProp.Value
        }
    }
}

Write-Host 'Collecting valid HREFs from sidebar definitions...' -ForegroundColor Cyan

$sidebarFiles = Get-ChildItem -Path $routesDir -Recurse -Filter 'primary-sidebar.json' -File

if ($sidebarFiles.Count -eq 0) {
    Write-Warning 'No primary-sidebar.json files found under src/routes.'
} else {
    foreach ($sf in $sidebarFiles) {
        $data = Get-Content $sf.FullName -Raw | ConvertFrom-Json
        if ($data) {
            Collect-Hrefs $data
        }
        $rel = $sf.FullName.Replace($RootDir, '').TrimStart([System.IO.Path]::DirectorySeparatorChar, '/')
        Write-Host "  $rel" -ForegroundColor DarkGray
    }
}

Write-Host "Found $($validHrefs.Count) valid HREF(s).`n" -ForegroundColor Cyan

# ── 2. Helpers ────────────────────────────────────────────────────────────────

# Regex: HTML anchor href attribute (double-quoted)
$htmlHrefRx = [regex]'<a\b[^>]*?\bhref="([^"]*)"'
# Regex: Markdown link [label](href) — skip images (preceded by !)
$mdLinkRx   = [regex]'(?<!!)\[[^\]]*\]\((/[^)]*)\)'

function Find-ClosestHref ([string]$Broken) {
    $lastSeg = ($Broken.TrimEnd('/') -split '/')[-1]
    foreach ($v in $validHrefs) {
        if (($v.TrimEnd('/') -split '/')[-1] -eq $lastSeg) {
            return $v
        }
    }
    return $null
}

# ── 3. Scan Markdown files ────────────────────────────────────────────────────

$mdFiles     = Get-ChildItem -Path $routesDir -Recurse -Filter '*.md' -File
$totalErrors = 0
$fixedCount  = 0

foreach ($mdFile in $mdFiles) {
    $lines       = Get-Content $mdFile.FullName
    $newLines    = [System.Collections.Generic.List[string]]::new()
    $fileChanged = $false

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $lineNum = $i + 1
        $line    = $lines[$i]
        $newLine = $line

        # ── HTML anchors ──────────────────────────────────────────────────────
        foreach ($m in $htmlHrefRx.Matches($line)) {
            $href = $m.Groups[1].Value
            if (-not $href.StartsWith('/')) { continue }           # skip non-absolute
            $hrefPath = ($href -split '#', 2)[0]                   # strip fragment
            if ($validHrefs.Contains($hrefPath)) { continue }      # link is valid

            $rel = $mdFile.FullName.Replace($RootDir, '').TrimStart([System.IO.Path]::DirectorySeparatorChar, '/')
            Write-Host "ERROR  ${rel}:${lineNum}" -ForegroundColor Red
            Write-Host "       HTML anchor href='$href' not found in any sidebar." -ForegroundColor Red
            $totalErrors++

            if ($shouldFix) {
                $closest = Find-ClosestHref $hrefPath
                if ($null -ne $closest) {
                    $replacement = if ($href -match '#') { "$closest#$($href -split '#', 2)[1]" } else { $closest }
                    $newLine = $newLine.Replace($href, $replacement)
                    $fileChanged = $true
                    Write-Host "  AUTO-FIX: '$href' → '$replacement'" -ForegroundColor Yellow
                    $fixedCount++
                }
            }
        }

        # ── Markdown links ────────────────────────────────────────────────────
        foreach ($m in $mdLinkRx.Matches($line)) {
            $href     = $m.Groups[1].Value
            $hrefPath = ($href -split '#', 2)[0]                   # strip fragment
            if ($validHrefs.Contains($hrefPath)) { continue }      # link is valid

            $rel = $mdFile.FullName.Replace($RootDir, '').TrimStart([System.IO.Path]::DirectorySeparatorChar, '/')
            Write-Host "ERROR  ${rel}:${lineNum}" -ForegroundColor Red
            Write-Host "       Markdown link href='$href' not found in any sidebar." -ForegroundColor Red
            $totalErrors++

            if ($shouldFix) {
                $closest = Find-ClosestHref $hrefPath
                if ($null -ne $closest) {
                    $replacement = if ($href -match '#') { "$closest#$($href -split '#', 2)[1]" } else { $closest }
                    $newLine = $newLine.Replace($href, $replacement)
                    $fileChanged = $true
                    Write-Host "  AUTO-FIX: '$href' → '$replacement'" -ForegroundColor Yellow
                    $fixedCount++
                }
            }
        }

        $newLines.Add($newLine)
    }

    if ($fileChanged) {
        Set-Content -Path $mdFile.FullName -Value $newLines
        $rel = $mdFile.FullName.Replace($RootDir, '').TrimStart([System.IO.Path]::DirectorySeparatorChar, '/')
        Write-Host "  Updated: $rel" -ForegroundColor Green
    }
}

# ── 4. Summary ────────────────────────────────────────────────────────────────

if ($shouldFix -and $fixedCount -gt 0) {
    Write-Host "`nAuto-fixed $fixedCount link(s)." -ForegroundColor Yellow
}

if ($totalErrors -eq 0) {
    Write-Host '✔ All internal links are valid.' -ForegroundColor Green
    exit 0
}

$remaining = $totalErrors - $fixedCount
if ($remaining -gt 0) {
    Write-Host "`n✖ $remaining broken link(s) found (of $totalErrors detected)." -ForegroundColor Red
    exit 1
} else {
    Write-Host "`n✔ All $totalErrors broken link(s) were auto-fixed." -ForegroundColor Green
    exit 0
}
