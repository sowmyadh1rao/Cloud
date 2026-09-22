resource "aws_cognito_user" "test_user" {
  user_pool_id = aws_cognito_user_pool.hr_app.id
  username     = "testuser@example.com"
  password     = "TempPassword123!"
  
  attributes = {
    email = "testuser@example.com"
  }

  lifecycle {
    ignore_changes = [password]
  }
}
