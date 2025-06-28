# VeneerVision AI - Serverless Backend

This is the AWS Lambda function for the VeneerVision AI project that handles Replicate API integration for dental veneer simulation.

## 🚀 Features

- **AWS Lambda Integration**: Serverless function for scalable AI processing
- **Replicate API**: Calls the `sourav-sarkar-doc32/smile-correct` model
- **CORS Support**: Configured for web application integration
- **Error Handling**: Comprehensive error handling and logging
- **Timeout Management**: Configurable polling with timeout protection

## 📋 Prerequisites

- Node.js 18.x or higher
- AWS CLI configured with appropriate permissions
- Replicate API token
- AWS Lambda execution role with basic permissions

## 🛠️ Installation & Setup

### 1. Install Dependencies

```bash
cd serverless-backend
npm install
```

### 2. Environment Variables

The function requires the following environment variables:

- `REPLICATE_API_TOKEN`: Your Replicate API token
- `REPLICATE_MODEL_VERSION`: (Optional) Model version ID (defaults to latest)

### 3. Build for Deployment

```bash
# Install production dependencies only
npm run install-deps

# Create deployment package
npm run zip
```

This creates a `function.zip` file ready for AWS Lambda upload.

## 📦 Manual Deployment

### Option 1: AWS Console

1. Go to AWS Lambda Console
2. Create a new function
3. Choose "Author from scratch"
4. Set runtime to "Node.js 18.x"
5. Upload the `function.zip` file
6. Configure environment variables
7. Set timeout to 5 minutes (300 seconds)
8. Set memory to 256 MB (minimum recommended)

### Option 2: AWS CLI

```bash
# Create the function
aws lambda create-function \
  --function-name veneer-vision-api \
  --runtime nodejs18.x \
  --role arn:aws:iam::YOUR-ACCOUNT:role/lambda-execution-role \
  --handler index.handler \
  --zip-file fileb://function.zip \
  --timeout 300 \
  --memory-size 256 \
  --environment Variables='{REPLICATE_API_TOKEN=your_token_here}'

# Update function code (for subsequent deployments)
aws lambda update-function-code \
  --function-name veneer-vision-api \
  --zip-file fileb://function.zip
```

## 🌐 API Gateway Integration

### Create API Gateway

1. Create a new REST API
2. Create a resource (e.g., `/predict`)
3. Create a POST method
4. Integrate with your Lambda function
5. Enable CORS if needed

### Example API Gateway Configuration

```json
{
  "swagger": "2.0",
  "info": {
    "title": "VeneerVision AI API",
    "version": "1.0.0"
  },
  "paths": {
    "/predict": {
      "post": {
        "summary": "Generate veneer simulation",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "type": "object",
              "properties": {
                "image_url": {
                  "type": "string",
                  "description": "URL of the image to process"
                }
              }
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Successful prediction",
            "schema": {
              "type": "object",
              "properties": {
                "success": { "type": "boolean" },
                "prediction_id": { "type": "string" },
                "output": { "type": "array" },
                "status": { "type": "string" }
              }
            }
          },
          "400": {
            "description": "Bad request - missing or invalid image_url"
          },
          "500": {
            "description": "Internal server error"
          }
        }
      },
      "options": {
        "summary": "CORS preflight",
        "responses": {
          "200": {
            "description": "CORS preflight successful"
          }
        }
      }
    }
  }
}
```

## 📡 API Usage

### Request Format

```json
POST /predict
Content-Type: application/json

{
  "image_url": "https://example.com/smile-image.jpg"
}
```

### Response Format

#### Success Response (200)

```json
{
  "success": true,
  "prediction_id": "abc123def456",
  "output": [
    "https://replicate.delivery/path/to/generated/image.png"
  ],
  "status": "succeeded",
  "created_at": "2024-01-01T12:00:00Z",
  "completed_at": "2024-01-01T12:02:30Z",
  "metrics": {
    "predict_time": 2.5
  }
}
```

#### Error Response (400/500)

```json
{
  "error": "Missing required parameter: image_url"
}
```

## 🔧 Configuration

### Lambda Function Settings

- **Runtime**: Node.js 18.x
- **Timeout**: 5 minutes (300 seconds)
- **Memory**: 256 MB (minimum)
- **Handler**: `index.handler`

### Environment Variables

| Variable | Required | Description | Default |
|----------|----------|-------------|---------|
| `REPLICATE_API_TOKEN` | Yes | Your Replicate API token | - |
| `REPLICATE_MODEL_VERSION` | No | Model version ID | Latest version |

### IAM Permissions

The Lambda execution role needs:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
```

## 🧪 Testing

### Local Testing

You can test the function locally using the AWS SAM CLI or by creating a test event:

```json
{
  "httpMethod": "POST",
  "body": "{\"image_url\": \"https://example.com/test-image.jpg\"}"
}
```

### Test with cURL

```bash
curl -X POST https://your-api-gateway-url/predict \
  -H "Content-Type: application/json" \
  -d '{"image_url": "https://example.com/smile-image.jpg"}'
```

## 📊 Monitoring

### CloudWatch Logs

The function automatically logs to CloudWatch with the following information:

- Prediction start/completion
- Polling attempts and status
- Error details
- Performance metrics

### Key Metrics to Monitor

- Function duration
- Error rate
- Memory usage
- API Gateway response times

## 🔒 Security Considerations

1. **API Token**: Store `REPLICATE_API_TOKEN` as an environment variable
2. **CORS**: Configure appropriate origins in API Gateway
3. **Rate Limiting**: Consider implementing rate limiting in API Gateway
4. **Input Validation**: The function validates image URLs
5. **Error Handling**: Sensitive information is not exposed in error responses

## 🚨 Troubleshooting

### Common Issues

1. **Timeout Errors**: Increase Lambda timeout or optimize polling intervals
2. **Memory Errors**: Increase Lambda memory allocation
3. **CORS Errors**: Check API Gateway CORS configuration
4. **Authentication Errors**: Verify Replicate API token is correct

### Debug Mode

Enable detailed logging by checking CloudWatch logs for the function.

## 📈 Performance Optimization

- **Memory**: Increase memory for faster execution
- **Polling**: Adjust polling intervals based on model performance
- **Caching**: Consider caching results for repeated requests
- **Concurrency**: Monitor and adjust concurrent execution limits

## 🔄 Updates and Maintenance

### Updating the Function

1. Make code changes
2. Run `npm run build` to create new zip file
3. Upload new zip to Lambda
4. Test the updated function

### Version Management

Consider using Lambda versions and aliases for production deployments.

## 📞 Support

For issues related to:
- **Lambda Function**: Check CloudWatch logs
- **Replicate API**: Check Replicate documentation
- **API Gateway**: Check AWS API Gateway documentation

---

**Version**: 1.0.0  
**Last Updated**: January 2024  
**Compatibility**: Node.js 18.x, AWS Lambda 