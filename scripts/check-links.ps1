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

# Returns the value of a named property on a PSCustomObject, or $null if absent.
function Get-PropertyValue ([object]$Obj, [string]$Name) {
    $prop = $Obj.PSObject.Properties[$Name]
    if ($null -ne $prop) { return $prop.Value }
    return $null
}

function Collect-Hrefs ([object[]]$Items) {
    foreach ($item in $Items) {
        $href     = Get-PropertyValue $item 'href'
        $articles = Get-PropertyValue $item 'articles'
        if ($null -ne $href -and $href -ne '') {
            $null = $validHrefs.Add([string]$href)
        }
        if ($null -ne $articles) {
            Collect-Hrefs $articles
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

# Regex: HTML anchor href attribute.
# Both alternatives are nested under href= so that neither arm can match
# a standalone quoted string unrelated to an anchor.
# Group 1 = double-quoted value, group 2 = single-quoted value.
# Using a double-quoted PS string with backtick-escaped double quotes (`")
# makes the actual regex pattern explicit and avoids relying on PowerShell's
# single-quote escape sequence ('').
# Actual regex: <a\b[^>]*?\bhref=(?:(?:"([^"]*)")|(?:'([^']*)'))
$htmlHrefRx = [regex]("<a\b[^>]*?\bhref=(?:(?:`"([^`"]*)`")|(?:'([^']*)'))")
# Regex: Markdown link [label](href) where href starts with '/'.
# The link text pattern (?:[^\\\]]|\\.)* handles escaped closing brackets (\])
# per the CommonMark spec:
#   [^\\\]]  — any character that is neither \ nor ]
#              (\\  = literal backslash;  \] = literal closing bracket)
#   \\.      — a backslash followed by any character (escape sequence)
# Images (which use ![text](url) syntax) are excluded via the negative
# lookbehind (?<!!) which fails if the [ is immediately preceded by !.
# The script processes files line-by-line, so the pattern never spans multiple
# lines and multiline considerations do not apply.
$mdLinkRx   = [regex]'(?<!!)\[(?:[^\\\]]|\\.)*\]\((/[^)]*)\)'

# Strips the fragment identifier from a URL path.
# -split '#', 2  splits on the FIRST '#' only, so paths such as
# '/page#section#note' return '/page' and the full fragment 'section#note'
# is preserved when rebuilding the replacement href.
function Get-PathWithoutFragment ([string]$Href) {
    return ($Href -split '#', 2)[0]
}

function Find-ClosestHref ([string]$Broken) {
    $lastSeg = ($Broken.TrimEnd('/') -split '/')[-1]
    foreach ($v in $validHrefs) {
        if (($v.TrimEnd('/') -split '/')[-1] -eq $lastSeg) {
            return $v
        }
    }
    return $null
}

# Returns the fixed href for a broken path, preserving any fragment identifier.
function Resolve-FixedHref ([string]$BrokenPath, [string]$OriginalHref) {
    $closest = Find-ClosestHref $BrokenPath
    if ($null -eq $closest) { return $null }
    if ($OriginalHref -match '#') {
        $fragment = ($OriginalHref -split '#', 2)[1]
        return "$closest#$fragment"
    }
    return $closest
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

        # Collect all broken link matches from both patterns and process them in
        # descending index order.  Descending order ensures that substituting a
        # match at a higher position does not shift the indices of matches at
        # lower positions, so each replacement is made at the correct offset.
        $allMatches = [System.Collections.Generic.List[object]]::new()

        # ── HTML anchors ──────────────────────────────────────────────────────
        # Only root-relative paths (starting with '/') are validated.
        # External URLs (http/https) and fragment-only refs (#anchor) do not
        # start with '/' and are therefore naturally excluded.
        foreach ($m in $htmlHrefRx.Matches($line)) {
            # Group 1: double-quoted href; Group 2: single-quoted href
            $hrefGroup = if ($m.Groups[1].Success) { $m.Groups[1] } else { $m.Groups[2] }
            $href = $hrefGroup.Value
            if (-not $href.StartsWith('/')) { continue }
            $hrefPath = Get-PathWithoutFragment $href
            if ($validHrefs.Contains($hrefPath)) { continue }
            $null = $allMatches.Add([PSCustomObject]@{
                Match    = $m
                Group    = $hrefGroup
                Href     = $href
                HrefPath = $hrefPath
                Kind     = 'HTML anchor'
            })
        }

        # ── Markdown links ────────────────────────────────────────────────────
        foreach ($m in $mdLinkRx.Matches($line)) {
            $href     = $m.Groups[1].Value
            $hrefPath = Get-PathWithoutFragment $href
            if ($validHrefs.Contains($hrefPath)) { continue }
            $null = $allMatches.Add([PSCustomObject]@{
                Match    = $m
                Group    = $m.Groups[1]
                Href     = $href
                HrefPath = $hrefPath
                Kind     = 'Markdown link'
            })
        }

        # ── Report errors and apply fixes in descending index order ──────────
        $rel = $mdFile.FullName.Replace($RootDir, '').TrimStart([System.IO.Path]::DirectorySeparatorChar, '/')
        foreach ($entry in ($allMatches | Sort-Object { $_.Group.Index } -Descending)) {
            Write-Host "ERROR  ${rel}:${lineNum}" -ForegroundColor Red
            Write-Host "       $($entry.Kind) href='$($entry.Href)' not found in any sidebar." -ForegroundColor Red
            $totalErrors++

            if ($shouldFix) {
                $replacement = Resolve-FixedHref $entry.HrefPath $entry.Href
                if ($null -ne $replacement) {
                    # Replace exactly this occurrence using the capture-group position.
                    $g       = $entry.Group
                    $newLine = $newLine.Substring(0, $g.Index) + $replacement + $newLine.Substring($g.Index + $g.Length)
                    $fileChanged = $true
                    Write-Host "  AUTO-FIX: '$($entry.Href)' → '$replacement'" -ForegroundColor Yellow
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
