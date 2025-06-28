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
3. **Replicate Processing**: Sends URL to Replicate API for veneer transformation
4. **Result Storage**: Downloads result and uploads to `outputs/{key}` in same bucket

## Prerequisites

- AWS CLI configured with appropriate permissions
- Node.js 18.x or later
- Existing IAM role `veneer-lambda-role` with S3 and Lambda permissions
- S3 bucket `veneer-vision-site-vvjun28` exists in us-east-1
- Replicate API token

## Quick Start

1. **Navigate to the s3-handler directory:**
   ```bash
   cd serverless-backend/s3-handler
   ```

2. **Update configuration:**
   - Edit `deploy.sh` and set your `REPLICATE_API_TOKEN`
   - Verify `ROLE_ARN` points to your IAM role
   - Confirm `BUCKET_NAME` and `REGION` are correct

3. **Deploy the function:**
   ```bash
   ./deploy.sh
   ```

4. **Test the deployment:**
   ```bash
   aws s3 cp test.jpg s3://veneer-vision-site-vvjun28/ --region us-east-1
   ```

## Configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `REPLICATE_API_TOKEN` | Your Replicate API token | Yes |
| `AWS_REGION` | AWS region (defaults to us-east-1) | No |

### Bucket / Region

- **Bucket**: `veneer-vision-site-vvjun28` (us-east-1)
- **Supported Formats**: JPG, PNG
- **Trigger Events**: PUT only
- **Output Location**: `outputs/{original-key}`

### Lambda Settings

- **Runtime**: Node.js 18.x
- **Timeout**: 300 seconds (5 minutes)
- **Memory**: 512 MB
- **Handler**: `index.handler`

## IAM Permissions

Your Lambda execution role needs:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::veneer-vision-site-vvjun28/*"
    },
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

## Testing

### Local Testing

```bash
node test-local.js
```

### S3 Testing

```bash
# Upload a test image
aws s3 cp test.jpg s3://veneer-vision-site-vvjun28/ --region us-east-1

# Check Lambda logs
aws logs tail /aws/lambda/veneer-s3-handler --follow --region us-east-1
```

### Expected Flow

1. Upload image to S3 bucket
2. Lambda function triggers automatically
3. Function calls Replicate API with image URL
4. Replicate processes image and returns result URL
5. Function downloads result and uploads to `outputs/{key}`
6. Check CloudWatch logs for processing details

## Troubleshooting

### Common Issues

1. **Bucket not found**: Verify bucket name and region
2. **Permission denied**: Check IAM role permissions
3. **Replicate API errors**: Verify API token and model availability
4. **Timeout errors**: Increase Lambda timeout if needed

### Logs

Check CloudWatch logs for detailed error information:

```bash
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/veneer-s3-handler" --region us-east-1
```

## Development

### File Structure

```
s3-handler/
├── index.js              # Main Lambda function
├── package.json          # Dependencies
├── deploy.sh            # Deployment script
├── test-local.js        # Local testing
├── test-event.json      # Sample S3 event
├── README.md            # This file
└── .gitignore           # Git ignore rules
```

### Adding Features

1. **New Image Formats**: Update S3 trigger filters in `deploy.sh`
2. **Additional Processing**: Modify `processS3Record()` in `index.js`
3. **Error Handling**: Add specific error cases in `handleReplicateError()`

## Support

For issues or questions:
1. Check CloudWatch logs first
2. Verify all prerequisites are met
3. Test with a simple image upload
4. Review IAM permissions and bucket configuration 