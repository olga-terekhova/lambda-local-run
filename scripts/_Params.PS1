$AwsCliImagePath = "..\aws-cli\" 					# relative to current script
$CredJsonPath = "aws/Cred.json"						# relative to aws image
$LambdaImageName = "docker-image-lambda:test"
$LambdaContainerName = "lambda-container"

$LambdaImagePath = "..\..\lambda-python-playwright-chromium"		# relative to current script
$RoleARN="arn:aws:iam::633389222153:role/playwright-test-access-role"
$Region = "ca-central-1"

$InvokeJsonPath = "..\..\lambda-python-playwright-chromium\test\event.json" # relative to current script

