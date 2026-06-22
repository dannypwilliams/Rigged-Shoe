Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Rigged Shoe Windows quick check"
Write-Host ""

$required = @(
  "RiggedShoe.xcodeproj/project.pbxproj",
  "RiggedShoe/App/RiggedShoeApp.swift",
  "RiggedShoe/App/ContentView.swift",
  "RiggedShoe/ViewModels/GameViewModel.swift",
  "Tools/Simulation/rigged_shoe_sim.py",
  "README_DEV.md"
)

foreach ($path in $required) {
  if (-not (Test-Path $path)) {
    throw "Missing required file: $path"
  }
  Write-Host "OK $path"
}

Write-Host ""
Write-Host "Source tree is present. Build and Simulator verification still require macOS/Xcode."
