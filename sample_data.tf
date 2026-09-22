# ============================================
# Sample Employee Data
# ============================================

resource "aws_dynamodb_table_item" "employee_1" {
  table_name = aws_dynamodb_table.employees.name
  hash_key   = aws_dynamodb_table.employees.hash_key

  item = jsonencode({
    EmployeeID = { S = "1001" }
    Name = { S = "Sowmya" }
    Salary = { N = "92000" }
    DateOfJoin = { S = "2024-01-15" }
    Description = { S = "arn:aws:iam::611622961093:user/sowmya" }
  })
}

resource "aws_dynamodb_table_item" "employee_2" {
  table_name = aws_dynamodb_table.employees.name
  hash_key   = aws_dynamodb_table.employees.hash_key

  item = jsonencode({
    EmployeeID = { S = "1002" }
    Name = { S = "Alice Chen" }
    Salary = { N = "95000" }
    DateOfJoin = { S = "2023-06-10" }
    Description = { S = "Cloud Engineering" }
  })
}

resource "aws_dynamodb_table_item" "employee_3" {
  table_name = aws_dynamodb_table.employees.name
  hash_key   = aws_dynamodb_table.employees.hash_key

  item = jsonencode({
    EmployeeID = { S = "1003" }
    Name = { S = "Bob Smith" }
    Salary = { N = "88000" }
    DateOfJoin = { S = "2024-03-20" }
    Description = { S = "Backend Developer" }
  })
}

resource "aws_dynamodb_table_item" "employee_4" {
  table_name = aws_dynamodb_table.employees.name
  hash_key   = aws_dynamodb_table.employees.hash_key

  item = jsonencode({
    EmployeeID = { S = "1004" }
    Name = { S = "Carol Davis" }
    Salary = { N = "98000" }
    DateOfJoin = { S = "2023-09-01" }
    Description = { S = "DevOps Engineer" }
  })
}

resource "aws_dynamodb_table_item" "employee_5" {
  table_name = aws_dynamodb_table.employees.name
  hash_key   = aws_dynamodb_table.employees.hash_key

  item = jsonencode({
    EmployeeID = { S = "1005" }
    Name = { S = "David Wilson" }
    Salary = { N = "85000" }
    DateOfJoin = { S = "2024-02-14" }
    Description = { S = "QA Engineer" }
  })
}
