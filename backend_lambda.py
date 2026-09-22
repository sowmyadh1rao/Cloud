import json
import boto3
import os
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

def lambda_handler(event, context):
    """
    Retrieves employee data from DynamoDB based on Employee ID
    Called by: GET /employee/{id}
    """
    try:
        # Extract Employee ID from path
        employee_id = event['pathParameters']['id']
        
        # Query DynamoDB
        response = table.get_item(
            Key={'EmployeeID': employee_id}
        )
        
        # Check if item exists
        if 'Item' not in response:
            return {
                'statusCode': 404,
                'headers': {
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'error': 'Employee not found',
                    'employeeId': employee_id
                })
            }
        
        # Return employee data
        employee = response['Item']
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'employeeId': employee['EmployeeID'],
                'name': employee['Name'],
                'salary': int(employee['Salary']),
                'dateOfJoin': employee['DateOfJoin'],
                'description': employee['Description']
            })
        }
    
    except KeyError as e:
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': 'Invalid request',
                'message': f'Missing parameter: {str(e)}'
            })
        }
    
    except ClientError as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': 'Database error',
                'message': str(e)
            })
        }
    
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        }
