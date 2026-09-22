# Serverless HR Lookup Application

Serverless employee lookup application using AWS Lambda, API Gateway, DynamoDB, and Cognito.

## Deployment Steps

### 1. Update terraform.tfvars
Update the `aws_account_id` with your AWS account ID:

```hcl
aws_account_id = "YOUR_AWS_ACCOUNT_ID"
```

### 2. Update Cognito URLs
Update `cognito_callback_urls` and `cognito_logout_urls` with your API Gateway endpoint:

```hcl
cognito_callback_urls = ["https://YOUR_API_ENDPOINT/prod/"]
cognito_logout_urls = ["https://YOUR_API_ENDPOINT/prod/"]
```

### 3. Initialize Terraform
```bash
terraform init
```

### 4. Plan Deployment
```bash
terraform plan
```

### 5. Package Lambda Functions
```bash
bash create_lambda_zip.sh
```

### 6. Apply Deployment
```bash
terraform apply
```

Type `yes` when prompted to create resources.

## Quick Test

1. Get the API endpoint from `terraform output`
2. Open the URL in browser
3. Login with: `testuser@example.com` / `TempPassword123!`
4. Search for employee ID: `1002`

## Architecture

- **Frontend:** Lambda + HTML/CSS/JavaScript
- **Backend:** Lambda + DynamoDB
- **API:** API Gateway REST
- **Auth:** Cognito User Pool
- **IaC:** Terraform

## Files

- `ui_lambda.py` - Frontend/UI handler
- `backend_lambda.py` - Employee lookup handler
- `main.tf` - AWS resources
- `variables.tf` - Variable definitions
- `terraform.tfvars` - Configuration values
- `sample_data.tf` - Employee seed data
- `test_user.tf` - Test user setup
- `create_lambda_zip.sh` - Lambda packaging script

## API Endpoints

- `GET /` - Application UI
- `GET /employee/{id}` - Get employee (requires Cognito ID token)

## Cleanup

```bash
terraform destroy
```

## Test Credentials

- **Email:** testuser@example.com
- **Password:** TempPassword123!

## Sample Employees

- 1001: Sowmya
- 1002: Bob Smith
- 1003: Carol Davis
- 1004: David Wilson
- 1005: Alice Johnson
