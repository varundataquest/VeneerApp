# VeneerVision AI S3 Handler Lambda Function

This Lambda function automatically processes images uploaded to the `veneer-vision-site-vvjune28` S3 bucket by applying AI-powered veneer transformations using the Replicate API.

## Features

- ✅ Triggers on S3 PUT events
- ✅ Extracts bucket and object key from S3 events
- ✅ Builds S3 object URLs for processing
- ✅ Calls Replicate API with "sourav-sarkar-doc32/smile-correct" model
- ✅ Downloads prediction results and uploads to S3
- ✅ Comprehensive error handling and logging
- ✅ Configurable timeout and memory settings

## Architecture

```
S3 Upload → Lambda Trigger → Replicate API → Download Result → S3 Upload
```

1. **S3 Event**: Image uploaded to bucket triggers Lambda
2. **URL Generation**: Builds S3 object URL (`https://bucket.s3.amazonaws.com/key`)
3. **AI Processing**: Sends URL to Replicate smile correction model
4. **Result Storage**: Downloads processed image and uploads to `outputs/{filename}_veneer.png`

## Prerequisites

- AWS CLI configured with appropriate permissions
- Node.js 18.x or later
- Existing IAM role `veneer-lambda-role` with S3 and Lambda permissions
- S3 bucket `veneer-vision-site-vvjune28` exists
- Replicate API token with access to "sourav-sarkar-doc32/smile-correct" model

## Required IAM Permissions

Your Lambda execution role needs these permissions:

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
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::veneer-vision-site-vvjune28/*"
    }
  ]
}
```

## Environment Variables

- `REPLICATE_API_TOKEN`: Your Replicate API token (required)

## Quick Start

1. **Navigate to the s3-handler directory:**
   ```bash
   cd serverless-backend/s3-handler
   ```

2. **Update deployment script:**
   - Set your AWS account ID in `ROLE_ARN`
   - Set your Replicate API token in `REPLICATE_API_TOKEN`

3. **Deploy the function:**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

4. **Test the function:**
   ```bash
   # Upload a test image to your S3 bucket
   aws s3 cp test-image.jpg s3://veneer-vision-site-vvjune28/
   ```

## Configuration

### Function Settings
- **Runtime**: Node.js 18.x
- **Handler**: `index.handler`
- **Timeout**: 300 seconds (5 minutes)
- **Memory**: 512 MB
- **Environment Variables**: `REPLICATE_API_TOKEN`

### S3 Trigger
- **Event Type**: `s3:ObjectCreated:Put`
- **Bucket**: `veneer-vision-site-vvjune28`
- **Prefix**: None (processes all PUT events)

## File Structure

```
outputs/
├── original_image_veneer.png    # Processed image
├── another_image_veneer.png     # Another processed image
└── ...
```

## Error Handling

The function includes comprehensive error handling:

- **Missing API Token**: Clear error message if `REPLICATE_API_TOKEN` is not set
- **Replicate API Errors**: Detailed logging of API failures
- **S3 Errors**: Proper error handling for upload/download failures
- **Timeout Handling**: 5-minute timeout with polling retries
- **Invalid Events**: Skips non-PUT events gracefully

## Monitoring

### CloudWatch Logs
Monitor function execution in CloudWatch:
```bash
aws logs tail /aws/lambda/veneer-s3-handler --follow --region us-east-1
```

### Key Metrics
- **Invocation Count**: Number of S3 events processed
- **Error Rate**: Failed processing attempts
- **Duration**: Processing time per image
- **Memory Usage**: Resource utilization

## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Ensure IAM role has S3 read/write permissions
   - Check Lambda execution role permissions

2. **Replicate API Errors**
   - Verify API token is valid and has sufficient credits
   - Check model availability and access

3. **Timeout Errors**
   - Increase function timeout if processing takes longer
   - Check network connectivity to Replicate API

4. **Memory Issues**
   - Increase memory allocation for large images
   - Monitor memory usage in CloudWatch

### Debug Mode
Enable detailed logging by checking CloudWatch logs for:
- S3 event details
- Replicate API requests/responses
- Image processing steps
- Upload/download operations

## Cost Optimization

- **Memory**: Start with 512MB, adjust based on performance
- **Timeout**: Set to 300 seconds for most images
- **Concurrency**: Monitor concurrent executions
- **Storage**: Processed images stored in S3 (pay per GB)

## Security

- **API Token**: Stored as environment variable (encrypted at rest)
- **S3 Access**: Least privilege permissions
- **Network**: HTTPS-only communication with Replicate API
- **Logging**: No sensitive data in logs

## Support

For issues or questions:
1. Check CloudWatch logs for detailed error messages
2. Verify all prerequisites are met
3. Test with a simple image first
4. Monitor Replicate API usage and credits 