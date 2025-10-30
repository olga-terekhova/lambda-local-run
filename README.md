# lambda-local-run
This project provides a modular PowerShell-based framework for building, credentializing, and running AWS Lambda–compatible containers locally, using Docker and temporary AWS credentials.  
An example of a Lambda function that could be run in a local emulator is at https://github.com/olga-terekhova/lambda-python-playwright-chromium. It lacks any features to execute code that needs AWS permissions, like S3 access, locally. This project allows to pass temporary AWS credentials to the local function to give it needed permissions.  

**Project Structure**  

```
lambda-local-run/
├── .gitignore
├── README.md
│
├── aws-cli/
│   ├── Dockerfile
│   │
│   ├── .aws/
│   │   ├── config
│   │   ├── credentials
│   │   └── credentials_example
│   │
│   └── aws/
│       ├── Cred.json
│       └── Cred_example.json
│
└── scripts/
    ├── Build-Local-Lambda.ps1
    ├── Get-Credentials-CLI-Container.ps1
    ├── Get-Credentials-CLI-Local.ps1
    ├── Invoke-Local-Lambda.PS1
    ├── Run-Local-Lambda.ps1
    ├── _Params.ps1
    └── _Params_example.ps1
```

**Module Descriptions**
| Path | Description |
|------|-------------|
|aws-cli/|Contains the Docker image setup and local credential management for AWS CLI operations|
|aws-cli/Dockerfile|Defines the aws-cli:test image for running AWS CLI commands in an isolated container. It uses the image from https://hub.docker.com/r/amazon/aws-cli.|
|aws-cli/.aws/|Local AWS user configuration and credential files (used as volume mounts inside the container).|
|aws-cli/.aws/config|Configuration for the region and output format (should be set to json).|
|aws-cli/.aws/credentials|Credentials for the local user that will temporarily assume the role with the needed Lambda permissions. Not commited for security reasons.|
|aws-cli/.aws/credentials_example|A reference template for credentials.|
|aws-cli/aws/|Stores JSON-formatted AWS credentials (Cred.json) retrieved by assuming the role with the needed Lambda permissions.|
|aws-cli/aws/Cred.json|Temporary credentials issued by assuming role. Not commited for security reasons.|
|aws-cli/aws/Cred_example.json|A reference template for  Cred.json.|
|scripts/|Holds PowerShell automation scripts for building images, obtaining temporary credentials, and running Lambda-like containers locally.|
|scripts/Build-Local-Lambda.ps1|Builds the required local Docker images for lambda. Path to a Dockerfile in a different repo should be specified.|
|scripts/Get-Credentials-CLI-Container.ps1|Uses the aws-cli:test container to assume an AWS role and save temporary credentials (via sts assume-role).|
|scripts/Get-Credentials-CLI-Local.ps1|Performs the same role-assumption logic as above, but using a locally installed AWS CLI instead of Docker.|
|scripts/Invoke-Local-Lambda.PS1|Invokes a lambda function and passes a payload from a custom json|
|scripts/Run-Local-Lambda.ps1|Launches the Lambda-like container locally (e.g., docker run ...) using temporary credentials from JSON. Verifies image presence, injects environment variables to pass credentials, and keeps the session open.|
|scripts/_Params.ps1|Configuration file defining paths, AWS role ARNs, and environment settings used by the above scripts. Not commited for security reasons.|
|scripts/_Params_example.ps1|A reference template for _Params.ps1.|
	

**User Guide**
1. (AWS) Set up IAM role and user:
   - the role will have the same permissions the lambda function is supposed to have, like an access to a specific S3 bucket;
   - the user will have permission to assume this role.
2. (Local) Set the credentials for the user from Step 1 in aws-cli/.aws/credentials.
3. (Local) Set the aws-cli/.aws/config by specifying your AWS region and making sure the output is json.
4. (Local) Locate a local repo with a dockerfile for building a lambda function:
   - it should implement the local AWS RIE emulator, like [lambda-python-playwright-chromium](https://github.com/olga-terekhova/lambda-python-playwright-chromium).
5. (Local) Update configuration in scripts/_Params.PS1:
   - set $LambdaImagePath to the directory from Step 4;
   - set $RoleARN to the ARN of the role from Step 1;
   - set $Region to your AWS region;
   - set $InvokeJsonPath to the path to a JSON containing a payload to test function invocation.  
6. (Local, calling AWS) Run AWS CLI to assume the needed role and save temporary credentials:
   - if you want to use a local installation of AWS CLI, run scripts/Get-Credentials-CLI-Local.ps1 ;
   - else run scripts/Get-Credentials-CLI-Container.ps1 .
7. (Local) Build lambda image by running scripts/Build-Local-Lambda.ps1.
8. (Local) Run lambda container by running scripts/Run-Local-Lambda.ps1.
9. (Local, calling AWS) Test invocation of the function by running scripts/Invoke-Local-Lambda.PS1 in a different terminal window.  
   
	
	
