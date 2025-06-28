#!/bin/bash

# VeneerVision AI S3 Handler Lambda Deployment Script
# This script deploys the S3 handler Lambda function

set -e

FUNCTION_NAME="veneer-s3-handler"
HANDLER="index.handler"
RUNTIME="nodejs18.x"
ROLE_ARN="arn:aws:iam::YOUR_ACCOUNT_ID:role/veneer-lambda-role"
BUCKET_NAME="veneer-vision-site-vvjune28"
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

echo "🗜️  Creating deployment package..."
npm run zip

echo "📤 Uploading function to AWS Lambda..."

# Check if function exists
if aws lambda get-function --function-name $FUNCTION_NAME --region $REGION &> /dev/null; then
    echo "🔄 Updating existing function..."
    aws lambda update-function-code \
        --function-name $FUNCTION_NAME \
        --zip-file fileb://function.zip \
        --region $REGION
    
    echo "⚙️  Updating function configuration..."
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

echo "🔗 Setting up S3 trigger..."

# Remove existing trigger if it exists
EXISTING_TRIGGER=$(aws lambda get-event-source-mapping \
    --function-name $FUNCTION_NAME \
    --region $REGION 2>/dev/null | jq -r '.UUID // empty')

if [ ! -z "$EXISTING_TRIGGER" ]; then
    echo "🗑️  Removing existing trigger..."
    aws lambda delete-event-source-mapping \
        --uuid $EXISTING_TRIGGER \
        --region $REGION
fi

# Create new S3 trigger
echo "➕ Creating S3 trigger..."
aws lambda create-event-source-mapping \
    --function-name $FUNCTION_NAME \
    --event-source-arn "arn:aws:s3:::$BUCKET_NAME" \
    --events "s3:ObjectCreated:Put" \
    --region $REGION

echo "✅ Deployment completed successfully!"
echo ""
echo "📋 Function Details:"
echo "   Name: $FUNCTION_NAME"
echo "   Runtime: $RUNTIME"
echo "   Handler: $HANDLER"
echo "   Timeout: 300 seconds"
echo "   Memory: 512 MB"
echo "   S3 Bucket: $BUCKET_NAME"
echo "   Trigger: PUT events only"
echo ""
echo "🔧 Next Steps:"
echo "   1. Update ROLE_ARN in this script with your actual IAM role ARN"
echo "   2. Set your REPLICATE_API_TOKEN in this script"
echo "   3. Ensure your IAM role has S3 read/write permissions"
echo "   4. Test by uploading an image to the S3 bucket"
echo ""
echo "🧹 Cleanup:"
echo "   rm function.zip" 