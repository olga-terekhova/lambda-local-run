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

# Source the parameter file to get $RoleARN, $CredJsonPath
. $paramPath


# Ensure variables are set
if (-not ($RoleARN -and $CredJsonPath)) {
    Write-Error "One or more required parameters are missing in $paramPath"
    exit 1
}


params 
- name of role
- path to json 


# Call command to asssume role and get credentials
aws sts assume-role --role-arn $RoleARN --role-session-name test-access > $CredJsonPath