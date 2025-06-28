#!/bin/bash

# VeneerVision AI S3 Handler Lambda Deployment Script
# This script deploys the S3 handler Lambda function

set -e

FUNCTION_NAME="veneer-s3-handler"
HANDLER="index.handler"
RUNTIME="nodejs18.x"
ROLE_ARN="arn:aws:iam::395882564547:role/veneer-lambda-role"
BUCKET_NAME="veneer-vision-site-vvjune28"
REGION="us-east-1"
REPLICATE_API_TOKEN="YOUR_REPLICATE_API_TOKEN"

echo "🚀 Starting deployment of $FUNCTION_NAME..."

# Prerequisites check
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

if [ ! -f "index.js" ]; then
    echo "❌ index.js not found. Please run this script from the s3-handler directory."
    exit 1
fi

echo "📦 Installing dependencies..."
npm install

echo "📄 Creating deployment package..."
npm run zip

echo "☁️ Verifying S3 bucket exists..."
if ! aws s3api head-bucket --bucket $BUCKET_NAME --region $REGION &> /dev/null; then
    echo "❌ S3 bucket '$BUCKET_NAME' not found in region '$REGION'."
    exit 1
fi

echo "🚀 Uploading function to AWS Lambda..."
if aws lambda get-function --function-name $FUNCTION_NAME --region $REGION &> /dev/null; then
    echo "🔄 Updating existing function..."
    aws lambda update-function-code \
        --function-name $FUNCTION_NAME \
        --zip-file fileb://function.zip \
        --region $REGION

    echo "⚙️ Updating function configuration..."
    aws lambda update-function-configuration \
        --function-name $FUNCTION_NAME \
        --runtime $RUNTIME \
        --handler $HANDLER \
        --timeout 300 \
        --memory-size 512 \
        --environment Variables="{REPLICATE_API_TOKEN=$REPLICATE_API_TOKEN}" \
        --region $REGION
else
    echo "🆕 Creating new function..."
    aws lambda create-function \
        --function-name $FUNCTION_NAME \
        --runtime $RUNTIME \
        --role $ROLE_ARN \
        --handler $HANDLER \
        --zip-file fileb://function.zip \
        --timeout 300 \
        --memory-size 512 \
        --environment Variables="{REPLICATE_API_TOKEN=$REPLICATE_API_TOKEN}" \
        --region $REGION
fi

echo "🔐 Adding S3 invoke permission to Lambda..."
aws lambda add-permission \
    --function-name $FUNCTION_NAME \
    --statement-id s3-invoke \
    --action lambda:InvokeFunction \
    --principal s3.amazonaws.com \
    --source-arn "arn:aws:s3:::$BUCKET_NAME" \
    --region $REGION 2>/dev/null || echo "⚠️ Permission already exists or failed to add"

echo "🔔 Setting up S3 notification trigger..."
aws s3api put-bucket-notification-configuration \
    --bucket $BUCKET_NAME \
    --notification-configuration '{
        "LambdaFunctionConfigurations": [
            {
                "LambdaFunctionArn": "arn:aws:lambda:'$REGION':'$(aws sts get-caller-identity --query Account --output text)':function:'$FUNCTION_NAME'",
                "Events": ["s3:ObjectCreated:*"]
            }
        ]
    }' \
    --region $REGION

echo "✅ Deployment complete!"
echo "👉 Test with: aws s3 cp test.jpg s3://$BUCKET_NAME/ --region $REGION"

echo "🧹 Cleaning up..."
rm -f function.zip

echo "✅ Deployment finished!" 
