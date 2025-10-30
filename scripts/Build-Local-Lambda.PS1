# Load parameters

param (
    [Alias("p")][string]$paramPath
)

# Default to ./Params.ps1 if not provided
if (-not $paramPath) {
    $paramPath = Join-Path -Path $PSScriptRoot -ChildPath "_Params.ps1"
}

# Check if parameter file exists
if (-not (Test-Path $paramPath)) {
    Write-Error "Parameter file not found at: $paramPath"
    exit 1
}

# Source the parameter file to get $LambdaImagePath, $LambdaImageName, $LambdaContainerName
. $paramPath


# Ensure variables are set
if (-not ($LambdaImagePath -and $LambdaImageName -and $LambdaContainerName)) {
    Write-Error "One or more required parameters are missing in $paramPath"
    exit 1
}


$startLocation = Get-Location

Set-Location $LambdaImagePath


$dockerCmd = "docker buildx build --platform linux/amd64 --provenance=false -t $LambdaImageName ."
Invoke-Expression  $dockerCmd

Set-Location $startLocation

Write-Host "Build finished"