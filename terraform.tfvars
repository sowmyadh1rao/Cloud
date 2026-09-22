# AWS Configuration
aws_region = "us-east-1"
aws_account_id = "611622961093"

# Application naming
app_name = "serverless-hr-app"
environment = "prod"

# DynamoDB Configuration
dynamodb_table_name = "employee-table"
dynamodb_billing_mode = "PAY_PER_REQUEST"  # or "PROVISIONED"
dynamodb_read_capacity = 5
dynamodb_write_capacity = 5

# Cognito Configuration
cognito_user_pool_name = "hr-app-user-pool"
cognito_user_pool_username_attributes = ["email"]
cognito_user_pool_password_min_length = 8
cognito_app_client_name = "hr-app-client"
cognito_callback_urls = ["https://r97uk1mdk3.execute-api.us-east-1.amazonaws.com/prod/"]
cognito_logout_urls = ["https://r97uk1mdk3.execute-api.us-east-1.amazonaws.com/prod/"]
cognito_allowed_oauth_scopes = ["openid", "email", "profile"]
cognito_default_redirect_uri = "https://r97uk1mdk3.execute-api.us-east-1.amazonaws.com/prod/"
cognito_allowed_oauth_flows = ["implicit", "code"]

# Lambda Configuration
lambda_runtime = "python3.11"
lambda_timeout = 30
lambda_memory_size = 256
ui_lambda_function_name = "hr-app-ui-handler"
backend_lambda_function_name = "hr-app-backend-handler"

# API Gateway Configuration
api_gateway_name = "hr-app-api"
api_gateway_description = "HR Employee Lookup Application API"
api_gateway_stage_name = "prod"

# IAM Configuration
lambda_execution_role_name = "hr-app-lambda-execution-role"

# Tags
common_tags = {
  Application = "serverless-hr-app"
  Environment = "dev"
  ManagedBy   = "Terraform"
}
