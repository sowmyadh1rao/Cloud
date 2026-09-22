# ============================================
# AWS Configuration Variables
# ============================================
variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

# ============================================
# Application Configuration Variables
# ============================================
variable "app_name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}

# ============================================
# DynamoDB Variables
# ============================================
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB employees table"
  type        = string
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode (PAY_PER_REQUEST or PROVISIONED)"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.dynamodb_billing_mode)
    error_message = "Billing mode must be either PAY_PER_REQUEST or PROVISIONED."
  }
}

variable "dynamodb_read_capacity" {
  description = "DynamoDB read capacity units (only used if billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "dynamodb_write_capacity" {
  description = "DynamoDB write capacity units (only used if billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

# ============================================
# Cognito Variables
# ============================================
variable "cognito_user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
}

variable "cognito_user_pool_username_attributes" {
  description = "Cognito user pool username attributes"
  type        = list(string)
  default     = ["email"]
}

variable "cognito_user_pool_password_min_length" {
  description = "Minimum password length for Cognito"
  type        = number
  default     = 8
}

variable "cognito_app_client_name" {
  description = "Name of the Cognito app client"
  type        = string
}

variable "cognito_callback_urls" {
  description = "Cognito callback URLs for OAuth flow"
  type        = list(string)
}

variable "cognito_logout_urls" {
  description = "Cognito logout redirect URLs"
  type        = list(string)
}

variable "cognito_allowed_oauth_flows" {
  description = "Cognito allowed OAuth flows"
  type        = list(string)
  default     = ["code"]
}

variable "cognito_allowed_oauth_scopes" {
  description = "Cognito allowed OAuth scopes"
  type        = list(string)
  default     = ["openid", "email", "profile"]
}

# ============================================
# Lambda Variables
# ============================================
variable "lambda_runtime" {
  description = "Lambda runtime environment"
  type        = string
  default     = "python3.11"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda function memory in MB"
  type        = number
  default     = 256
}

variable "ui_lambda_function_name" {
  description = "Name of the UI Lambda function"
  type        = string
}

variable "backend_lambda_function_name" {
  description = "Name of the backend Lambda function"
  type        = string
}

# ============================================
# API Gateway Variables
# ============================================
variable "api_gateway_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "api_gateway_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = ""
}

variable "api_gateway_stage_name" {
  description = "Stage name for API Gateway deployment"
  type        = string
  default     = "prod"
}

# ============================================
# IAM Variables
# ============================================
variable "lambda_execution_role_name" {
  description = "Name of the Lambda execution IAM role"
  type        = string
}

variable "cognito_user_pool_client_name" {
  description = "Cognito User Pool Client Name"
  type        = string
  default     = "hr-app-client"
}

