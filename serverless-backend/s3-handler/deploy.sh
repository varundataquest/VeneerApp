#!/bin/bash

# VeneerVision AI S3 Handler Lambda Deployment Script
# This script deploys the S3 handler Lambda function

set -e

FUNCTION_NAME="veneer-s3-handler"
HANDLER="index.handler"
RUNTIME="nodejs18.x"
ROLE_ARN="arn:aws:iam::395882564547:role/veneer-lambda-role"
BUCKET_NAME="veneer-vision-site-vvjun28"
REGION="us-east-1"
REPLICATE_API_TOKEN="YOUR_REPLICATE_API_TOKEN"

echo "🚀 Starting deployment of $FUNCTION_NAME..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "index.js" ]; then
    echo "❌ index.js not found. Please run this script from the s3-handler directory."
    exit 1
fi

echo "📦 Installing dependencies..."
npm install

echo "🔎 Verifying bucket $BUCKET_NAME exists in $REGION..."
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" --region "$REGION" 2>/dev/null; then
    echo "❌ Bucket $BUCKET_NAME not found in $REGION" && exit 1
fi

echo "📦 Creating deployment package..."
npm run zip

echo "🔄 Uploading function to AWS Lambda..."
aws lambda create-function \
    --function-name "$FUNCTION_NAME" \
    --runtime "$RUNTIME" \
    --role "$ROLE_ARN" \
    --handler "$HANDLER" \
    --zip-file fileb://function.zip \
    --timeout 300 \
    --memory-size 512 \
    --environment Variables="{REPLICATE_API_TOKEN=$REPLICATE_API_TOKEN}" \
    --region "$REGION" \
    --description "VeneerVision AI S3 Handler - Processes uploaded images with Replicate API" \
    --tags Key=Project,Value=VeneerVision Key=Environment,Value=Production || \
aws lambda update-function-code \
    --function-name "$FUNCTION_NAME" \
    --zip-file fileb://function.zip \
    --region "$REGION"

echo "🔧 Setting up S3 trigger..."
aws s3api put-bucket-notification-configuration \
    --bucket "$BUCKET_NAME" \
    --notification-configuration '{
        "LambdaConfigurations": [
            {
                "Id": "veneer-s3-handler-trigger",
                "LambdaFunctionArn": "arn:aws:lambda:'$REGION':395882564547:function:'$FUNCTION_NAME'",
                "Events": ["s3:ObjectCreated:Put"],
                "Filter": {
                    "Key": {
                        "FilterRules": [
                            {
                                "Name": "suffix",
                                "Value": ".jpg"
                            }
                        ]
                    }
                }
            },
            {
                "Id": "veneer-s3-handler-trigger-png",
                "LambdaFunctionArn": "arn:aws:lambda:'$REGION':395882564547:function:'$FUNCTION_NAME'",
                "Events": ["s3:ObjectCreated:Put"],
                "Filter": {
                    "Key": {
                        "FilterRules": [
                            {
                                "Name": "suffix",
                                "Value": ".png"
                            }
                        ]
                    }
                }
            }
        ]
    }' \
    --region "$REGION"

echo "✅ Lambda function deployed successfully!"
echo "📋 Function Details:"
echo "   Name: $FUNCTION_NAME"
echo "   Runtime: $RUNTIME"
echo "   Handler: $HANDLER"
echo "   Bucket: $BUCKET_NAME"
echo "   Region: $REGION"
echo "   Timeout: 300 seconds"
echo "   Memory: 512 MB"

echo "🧹 Cleaning up..."
rm -f function.zip

echo "✅ Deployment finished! Test with: aws s3 cp test.jpg s3://$BUCKET_NAME/ --region $REGION" 
