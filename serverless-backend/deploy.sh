#!/bin/bash

# VeneerVision AI - Lambda Deployment Script
# This script builds and packages the Lambda function for deployment

set -e  # Exit on any error

echo "🚀 VeneerVision AI - Lambda Deployment Script"
echo "=============================================="

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Please run this script from the serverless-backend directory."
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js is not installed. Please install Node.js 18.x or higher."
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Error: Node.js version 18.x or higher is required. Current version: $(node -v)"
    exit 1
fi

echo "✅ Node.js version: $(node -v)"

# Clean up previous builds
echo "🧹 Cleaning up previous builds..."
rm -rf node_modules function.zip

# Install dependencies
echo "📦 Installing dependencies..."
npm install --production

# Check if dependencies were installed correctly
if [ ! -d "node_modules" ]; then
    echo "❌ Error: Failed to install dependencies"
    exit 1
fi

# Create deployment package
echo "📦 Creating deployment package..."
zip -r function.zip . -x "*.git*" "node_modules/.cache/*" "*.DS_Store" "deploy.sh" "README.md" "*.log"

# Check if zip was created successfully
if [ ! -f "function.zip" ]; then
    echo "❌ Error: Failed to create function.zip"
    exit 1
fi

# Get file size
ZIP_SIZE=$(du -h function.zip | cut -f1)
echo "✅ Deployment package created: function.zip ($ZIP_SIZE)"

# Check if zip size is reasonable (should be under 50MB for Lambda)
ZIP_SIZE_BYTES=$(stat -f%z function.zip 2>/dev/null || stat -c%s function.zip 2>/dev/null || echo "0")
ZIP_SIZE_MB=$((ZIP_SIZE_BYTES / 1024 / 1024))

if [ "$ZIP_SIZE_MB" -gt 50 ]; then
    echo "⚠️  Warning: Deployment package is larger than 50MB ($ZIP_SIZE_MB MB)"
    echo "   This may cause issues with Lambda deployment."
    echo "   Consider using Lambda Layers for large dependencies."
fi

echo ""
echo "🎉 Build completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Upload function.zip to AWS Lambda"
echo "2. Set environment variables:"
echo "   - REPLICATE_API_TOKEN"
echo "   - REPLICATE_MODEL_VERSION (optional)"
echo "3. Configure Lambda settings:"
echo "   - Runtime: Node.js 18.x"
echo "   - Timeout: 5 minutes (300 seconds)"
echo "   - Memory: 256 MB (minimum)"
echo "   - Handler: index.handler"
echo ""
echo "🔗 AWS CLI deployment command:"
echo "aws lambda create-function \\"
echo "  --function-name veneer-vision-api \\"
echo "  --runtime nodejs18.x \\"
echo "  --role arn:aws:iam::YOUR-ACCOUNT:role/lambda-execution-role \\"
echo "  --handler index.handler \\"
echo "  --zip-file fileb://function.zip \\"
echo "  --timeout 300 \\"
echo "  --memory-size 256 \\"
echo "  --environment Variables='{REPLICATE_API_TOKEN=your_token_here}'"
echo ""
echo "📖 For detailed instructions, see README.md" 