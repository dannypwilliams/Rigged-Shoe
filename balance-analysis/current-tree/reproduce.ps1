param(
    [ValidateSet("smoke", "audit")]
    [string]$Mode = "smoke",
    [int]$RunsPerPolicy = 1000,
    [int]$PairedRuns = 250,
    [int]$Workers = 0,
    [UInt64]$Seed = 20260622,
    [switch]$Resume,
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

$AnalysisRoot = $PSScriptRoot
$RepoRoot = Split-Path -Parent (Split-Path -Parent $AnalysisRoot)
$SimulatorSource = Join-Path $AnalysisRoot "tools\BalanceSimulator.cs"

if (!(Test-Path -LiteralPath $SimulatorSource)) {
    throw "Missing simulator source: $SimulatorSource"
}

if ($Workers -le 0) {
    $logical = [Environment]::ProcessorCount
    $Workers = [Math]::Max(1, $logical - 1)
}

if ($Mode -eq "audit") {
    if ($RunsPerPolicy -lt 100000) { $RunsPerPolicy = 100000 }
    if ($PairedRuns -lt 3000) { $PairedRuns = 3000 }
}

if (-not $SkipBuild) {
    Add-Type -Path $SimulatorSource -ReferencedAssemblies @("System.Core.dll")
}

[RiggedShoeBalance.BalanceSimulator]::Run(
    $RepoRoot,
    $AnalysisRoot,
    $Mode,
    $RunsPerPolicy,
    $PairedRuns,
    $Workers,
    $Seed,
    [bool]$Resume
)
