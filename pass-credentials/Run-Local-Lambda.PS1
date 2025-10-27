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

# Source the parameter file to get $LambdaImageName, $AwsCliImagePath, $CredJsonPath, $Region, $LambdaContainerName
. $paramPath


# Ensure variables are set
if (-not ($LambdaImageName -and $AwsCliImagePath -and $CredJsonPath -and $Region -and $LambdaContainerName)) {
    Write-Error "One or more required parameters are missing in $paramPath"
    exit 1
}



# Read and parse json with temporary credentials

$credFile = Join-Path $AwsCliImagePath $CredJsonPath 
Write-Host $credFile

if (-not (Test-Path $credFile)) {
    Write-Error "json with credentials not found"
    exit 1
}

$roleCred = Get-Content -Raw -Path $credFile | ConvertFrom-Json


# Check if credentials are still valid ---

$expiration = [DateTime]$roleCred.Credentials.Expiration
$currDateTime = Get-Date

if ($expiration -le $currDateTime) {
    Write-Error "Credentials expired at $expiration (UTC). Run Get-Credentials-CLI-Container.PS1 or Get-Credentials-CLI-Local.PS1 again."
    exit 1
}
else {
	$remaining = [math]::Round(($expiration - $currDateTime).TotalMinutes, 1)
	Write-Host "Credentials valid until " $expiration ". Remaining minutes: " $remaining
}

$AccessKey = $roleCred.Credentials.AccessKeyId
$SecretKey = $roleCred.Credentials.SecretAccessKey
$SessionToken = $roleCred.Credentials.SessionToken

$CredEnv = "-e AWS_ACCESS_KEY_ID='$AccessKey' -e AWS_SECRET_ACCESS_KEY='$SecretKey' -e AWS_SESSION_TOKEN='$SessionToken'"

$dockerCmd = "docker run --name $LambdaContainerName --platform linux/amd64 -p 9000:8080 -e TZ=UTC $CredEnv -e AWS_REGION='$Region' $LambdaImageName"

# Remove old container if it exists
$existing = docker ps -a --filter "name=$LambdaContainerName" --format "{{.ID}}"
if ($existing) {
    Write-Host "Removing existing $LambdaContainerName..."
    docker stop $LambdaContainerName | Out-Null
    docker rm $LambdaContainerName | Out-Null
}

# Check if image exists

if (docker images -q $LambdaImageName) {
    Write-Host "Image '$LambdaImageName' already exists locally."
    
    # Run container
    Invoke-Expression $dockerCmd 

} else {
    Write-Host "Image '$LambdaImageName' not found. You may need to build it first."
}



Write-Host "Finished"