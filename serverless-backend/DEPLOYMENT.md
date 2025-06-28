# 🚀 Quick Deployment Guide

## Prerequisites

- AWS CLI configured with appropriate permissions
- Replicate API token
- Node.js 18.x or higher

## Quick Start

### 1. Build the Package

```bash
cd serverless-backend
./deploy.sh
```

This will:
- Install dependencies
- Create `function.zip` (ready for upload)
- Show deployment instructions

### 2. Deploy to AWS Lambda

#### Option A: AWS Console (Recommended for first deployment)

1. Go to [AWS Lambda Console](https://console.aws.amazon.com/lambda/)
2. Click "Create function"
3. Choose "Author from scratch"
4. Fill in:
   - **Function name**: `veneer-vision-api`
   - **Runtime**: `Node.js 18.x`
   - **Architecture**: `x86_64`
5. Click "Create function"
6. In the "Code" tab, click "Upload from" → ".zip file"
7. Upload `function.zip`
8. Click "Save"

#### Option B: AWS CLI

```bash
aws lambda create-function \
  --function-name veneer-vision-api \
  --runtime nodejs18.x \
  --role arn:aws:iam::YOUR-ACCOUNT:role/lambda-execution-role \
  --handler index.handler \
  --zip-file fileb://function.zip \
  --timeout 300 \
  --memory-size 256
```

### 3. Configure Environment Variables

In the Lambda console:
1. Go to "Configuration" → "Environment variables"
2. Add:
   - `REPLICATE_API_TOKEN` = your_replicate_api_token
   - `REPLICATE_MODEL_VERSION` = 4956c634b9aa976129f13166c713f8cf38bd337cd58c77925e8cd71d935d5696 (optional)

### 4. Configure Function Settings

- **Timeout**: 5 minutes (300 seconds)
- **Memory**: 256 MB (minimum)

### 5. Create API Gateway

1. Go to [API Gateway Console](https://console.aws.amazon.com/apigateway/)
2. Create new REST API
3. Create resource `/predict`
4. Create POST method
5. Integrate with your Lambda function
6. Deploy the API

## Testing

```bash
curl -X POST https://your-api-gateway-url/predict \
  -H "Content-Type: application/json" \
  -d '{"image_url": "https://example.com/smile-image.jpg"}'
```

## Troubleshooting

- **Timeout errors**: Increase Lambda timeout
- **Memory errors**: Increase Lambda memory
- **CORS errors**: Configure CORS in API Gateway
- **Authentication errors**: Check Replicate API token

## Next Steps

1. Set up monitoring with CloudWatch
2. Configure custom domain
3. Set up CI/CD pipeline
4. Add rate limiting

For detailed instructions, see [README.md](README.md). 