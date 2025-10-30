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

# Source the parameter file to get $InvokeJsonPath
. $paramPath


# Ensure variables are set
if (-not ($InvokeJsonPath)) {
    Write-Error "One or more required parameters are missing in $paramPath"
    exit 1
}

# Read JSON file and collapse it into a single line
$JsonContent = Get-Content -Raw -Path $InvokeJsonPath | ConvertFrom-Json | ConvertTo-Json -Compress

# Invoke the function locally
Invoke-WebRequest -Uri "http://localhost:9000/2015-03-31/functions/function/invocations" -Method Post -Body $JsonContent -ContentType "application/json"

Write-Host "Finished"

