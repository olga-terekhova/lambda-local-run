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

# Source the parameter file to get $AwsCliImagePath, $RoleARN, $CredJsonPath
. $paramPath


# Ensure variables are set
if (-not ($AwsCliImagePath -and $RoleARN -and $CredJsonPath)) {
    Write-Error "One or more required parameters are missing in $paramPath"
    exit 1
}


# Go to the directory with the AWS CLI image
$startLocation = Get-Location

Set-Location $AwsCliImagePath

# Build image for AWS CLI
docker buildx build --platform linux/amd64 --provenance=false -t aws-cli:test .

# Set alias aws for the container
Function awscli { docker run --rm -v ./.aws:/root/.aws  -v ./aws:/aws --name aws-cli-container --platform linux/amd64 aws-cli:test @args }
Set-Alias aws awscli

# Call command to asssume role and get credentials
aws sts assume-role --role-arn $RoleARN --role-session-name test-access > $CredJsonPath

Set-Location $startLocation

Write-Host "Finished"
