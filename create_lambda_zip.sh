#!/bin/bash

# Script to create placeholder Lambda function ZIP file
# This should be run before terraform apply

set -e

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Create a simple Python Lambda handler
cat > "$TEMP_DIR/index.py" << 'EOF'
"""
Placeholder Lambda handler
Replace this with actual implementation
"""
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Placeholder Lambda handler
    """
    logger.info(f"Event: {json.dumps(event)}")
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Placeholder Lambda function',
            'event': event
        })
    }
EOF

# Create ZIP file
cd "$TEMP_DIR"
zip lambda_placeholder.zip index.py

# Move to current directory
mv lambda_placeholder.zip ../

echo "✓ Lambda placeholder ZIP created: lambda_placeholder.zip"
echo "  Replace index.py with actual Lambda code before deployment"
