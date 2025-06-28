const { handler } = require('./index');

// Mock S3 event for testing
const testEvent = {
  "Records": [
    {
      "eventVersion": "2.1",
      "eventSource": "aws:s3",
      "awsRegion": "us-east-1",
      "eventTime": "2024-01-01T12:00:00.000Z",
      "eventName": "ObjectCreated:Put",
      "userIdentity": {
        "principalId": "EXAMPLE"
      },
      "requestParameters": {
        "sourceIPAddress": "127.0.0.1"
      },
      "responseElements": {
        "x-amz-request-id": "EXAMPLE123456789",
        "x-amz-id-2": "EXAMPLE123/5678abcdefghijklambdaisawesome/mnopqrstuvwxyzABCDEFGH"
      },
      "s3": {
        "s3SchemaVersion": "1.0",
        "configurationId": "testConfigRule",
        "bucket": {
          "name": "veneer-vision-site-vvjune28",
          "ownerIdentity": {
            "principalId": "EXAMPLE"
          },
          "arn": "arn:aws:s3:::veneer-vision-site-vvjune28"
        },
        "object": {
          "key": "test-images/smile-test.jpg",
          "size": 1024,
          "eTag": "0123456789abcdef0123456789abcdef",
          "sequencer": "0A1B2C3D4E5F678901"
        }
      }
    }
  ]
};

async function testHandler() {
  console.log('🧪 Testing Lambda function locally...');
  console.log('📝 Test event:', JSON.stringify(testEvent, null, 2));
  
  try {
    // Set environment variable for testing
    process.env.REPLICATE_API_TOKEN = 'test-token';
    
    const result = await handler(testEvent);
    console.log('✅ Test completed successfully!');
    console.log('📊 Result:', JSON.stringify(result, null, 2));
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    console.error('🔍 Error details:', error);
  }
}

// Run the test
testHandler(); 