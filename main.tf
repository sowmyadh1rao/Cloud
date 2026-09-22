terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ============================================
# DynamoDB Table
# ============================================
resource "aws_dynamodb_table" "employees" {
  name         = var.dynamodb_table_name
  billing_mode = var.dynamodb_billing_mode
  hash_key     = "EmployeeID"

  attribute {
    name = "EmployeeID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(
    var.common_tags,
    {
      Name = var.dynamodb_table_name
    }
  )
}

# ============================================
# Cognito User Pool
# ============================================
resource "aws_cognito_user_pool" "hr_app" {
  name = var.cognito_user_pool_name

  username_attributes = var.cognito_user_pool_username_attributes

  password_policy {
    minimum_length    = var.cognito_user_pool_password_min_length
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  mfa_configuration = "OPTIONAL"

  software_token_mfa_configuration {
    enabled = true
  }

  auto_verified_attributes = ["email"]

  tags = merge(
    var.common_tags,
    {
      Name = var.cognito_user_pool_name
    }
  )
  lifecycle {
    ignore_changes = [schema]
  }
}

resource "aws_cognito_user_pool_client" "hr_app" {
  name                = var.cognito_user_pool_client_name
  user_pool_id        = aws_cognito_user_pool.hr_app.id
  generate_secret     = false
  
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]
  
  # OAuth Configuration
  allowed_oauth_flows = ["implicit", "code"]
  allowed_oauth_scopes = ["openid", "email", "profile"]
  allowed_oauth_flows_user_pool_client = true
  
  callback_urls = var.cognito_callback_urls
  logout_urls   = var.cognito_logout_urls

}

# ============================================
# Cognito User Pool Domain
# ============================================
resource "aws_cognito_user_pool_domain" "hr_app" {
  domain       = "serverless-hr-app-dev-${var.aws_account_id}"
  user_pool_id = aws_cognito_user_pool.hr_app.id
}

# ============================================
# Cognito Resource Server (optional - for scopes)
# ============================================
resource "aws_cognito_resource_server" "hr_app" {
  identifier   = "hr-app-api"
  name         = "HR App API"
  user_pool_id = aws_cognito_user_pool.hr_app.id

  scope {
    scope_name        = "read"
    scope_description = "Read employee data"
  }

  depends_on = [aws_cognito_user_pool.hr_app]
}

# ============================================
# IAM Execution Role for Lambda
# ============================================
resource "aws_iam_role" "lambda_execution_role" {
  name = var.lambda_execution_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = var.lambda_execution_role_name
    }
  )
}

# ============================================
# IAM Policy for DynamoDB Read Access (Backend Lambda)
# ============================================
resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name   = "lambda-dynamodb-read-policy"
  role   = aws_iam_role.lambda_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.employees.arn
      }
    ]
  })
}

# ============================================
# IAM Policy for CloudWatch Logs
# ============================================
resource "aws_iam_role_policy" "lambda_logs_policy" {
  name   = "lambda-logs-policy"
  role   = aws_iam_role.lambda_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/*"
      }
    ]
  })
}

# ============================================
# Lambda for UI
# ============================================
resource "aws_lambda_function" "ui_handler" {
  filename      = "ui_lambda.zip"
  function_name = var.ui_lambda_function_name
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name = var.ui_lambda_function_name
    }
  )

  depends_on = [aws_iam_role_policy.lambda_logs_policy]
}

# ============================================
# Lambda for Backend
# ============================================
resource "aws_lambda_function" "backend_handler" {
  filename      = "backend_lambda.zip"
  function_name = var.backend_lambda_function_name
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.employees.name
      ENVIRONMENT    = var.environment
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name = var.backend_lambda_function_name
    }
  )

  depends_on = [aws_iam_role_policy.lambda_dynamodb_policy]
}

# ============================================
# API Gateway REST API
# ============================================
resource "aws_api_gateway_rest_api" "hr_app" {
  name        = var.api_gateway_name
  description = var.api_gateway_description

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = var.api_gateway_name
    }
  )
}

# ============================================
# API Gateway Method: GET /
# ============================================
resource "aws_api_gateway_method" "get_root" {
  rest_api_id      = aws_api_gateway_rest_api.hr_app.id
  resource_id      = aws_api_gateway_rest_api.hr_app.root_resource_id
  http_method      = "GET"
  authorization    = "NONE"
}

resource "aws_api_gateway_integration" "get_root_integration" {
  rest_api_id      = aws_api_gateway_rest_api.hr_app.id
  resource_id      = aws_api_gateway_rest_api.hr_app.root_resource_id
  http_method      = aws_api_gateway_method.get_root.http_method
  type             = "AWS_PROXY"
  integration_http_method = "POST"
  uri              = aws_lambda_function.ui_handler.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_ui" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ui_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.hr_app.execution_arn}/*/*"
}

# ============================================
# API Gateway Resource: /employee/{id}
# ============================================
resource "aws_api_gateway_resource" "employee_id" {
  rest_api_id = aws_api_gateway_rest_api.hr_app.id
  parent_id   = aws_api_gateway_rest_api.hr_app.root_resource_id
  path_part   = "employee"
}

resource "aws_api_gateway_resource" "employee_id_path" {
  rest_api_id = aws_api_gateway_rest_api.hr_app.id
  parent_id   = aws_api_gateway_resource.employee_id.id
  path_part   = "{id}"
}

# ============================================
# Cognito Authorizer
# ============================================
resource "aws_api_gateway_authorizer" "cognito" {
  name          = "CognitoAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.hr_app.id
  provider_arns = ["arn:aws:cognito-idp:us-east-1:611622961093:userpool/us-east-1_wYiFtn2Xm"]

  identity_source = "method.request.header.Authorization"
}

# ============================================
# API Gateway Method: GET /employee/{id}
# ============================================
resource "aws_api_gateway_method" "get_employee" {
  rest_api_id      = aws_api_gateway_rest_api.hr_app.id
  resource_id      = aws_api_gateway_resource.employee_id_path.id
  http_method      = "GET"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.cognito.id
  request_parameters = {
    "method.request.path.id" = true
  }
}

resource "aws_api_gateway_integration" "get_employee_integration" {
  rest_api_id      = aws_api_gateway_rest_api.hr_app.id
  resource_id      = aws_api_gateway_resource.employee_id_path.id
  http_method      = aws_api_gateway_method.get_employee.http_method
  type             = "AWS_PROXY"
  integration_http_method = "POST"
  uri              = aws_lambda_function.backend_handler.invoke_arn

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
}

resource "aws_lambda_permission" "api_gateway_backend" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.hr_app.execution_arn}/*/*"
}

# ============================================
# API Gateway Deployment
# ============================================
resource "aws_api_gateway_deployment" "hr_app" {
  rest_api_id = aws_api_gateway_rest_api.hr_app.id

  depends_on = [
    aws_api_gateway_integration.get_root_integration,
    aws_api_gateway_integration.get_employee_integration
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# ============================================
# API Gateway Stage
# ============================================
resource "aws_api_gateway_stage" "hr_app" {
  deployment_id = aws_api_gateway_deployment.hr_app.id
  rest_api_id   = aws_api_gateway_rest_api.hr_app.id
  stage_name    = var.api_gateway_stage_name

  xray_tracing_enabled = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.api_gateway_name}-${var.api_gateway_stage_name}"
    }
  )
}

# ============================================
# Data Source: Current AWS Account
# ============================================
data "aws_caller_identity" "current" {}
