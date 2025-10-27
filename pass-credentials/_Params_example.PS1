$AwsCliImagePath = "..\aws-cli\" 					# relative to current script
$CredJsonPath = "aws/Cred.json"						# relative to aws image
$LambdaImagePath = "..\..\lambda-python-playwright-chromium"		# relative to current script
$LambdaImageName = "docker-image-lambda:test"
$LambdaContainerName = "lambda-container"

$RoleARN="arn:aws:iam::3143423143131431:role/test-access-role"
$Region = "ca-central-1"

