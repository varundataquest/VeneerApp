const axios = require('axios');

// Lambda handler function
exports.handler = async (event) => {
  // Set CORS headers for API Gateway
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
    'Access-Control-Allow-Methods': 'POST,OPTIONS'
  };

  // Handle OPTIONS requests for CORS preflight
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ message: 'CORS preflight successful' })
    };
  }

  try {
    // Parse the request body
    const body = JSON.parse(event.body || '{}');
    const { image_url } = body;

    // Validate input
    if (!image_url) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({
          error: 'Missing required parameter: image_url'
        })
      };
    }

    // Validate image URL format
    if (!image_url.startsWith('http://') && !image_url.startsWith('https://')) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({
          error: 'Invalid image_url format. Must be a valid HTTP/HTTPS URL.'
        })
      };
    }

    // Get API token from environment
    const apiToken = process.env.REPLICATE_API_TOKEN;
    if (!apiToken) {
      return {
        statusCode: 500,
        headers,
        body: JSON.stringify({
          error: 'REPLICATE_API_TOKEN environment variable not configured'
        })
      };
    }

    // Replicate API configuration
    const modelVersion = process.env.REPLICATE_MODEL_VERSION || '4956c634b9aa976129f13166c713f8cf38bd337cd58c77925e8cd71d935d5696';
    const model = 'sourav-sarkar-doc32/smile-correct';

    console.log(`Starting prediction with model: ${model}, version: ${modelVersion}`);
    console.log(`Image URL: ${image_url}`);

    // Create prediction request
    const predictionData = {
      version: modelVersion,
      input: {
        image: image_url,
        prompt: 'photo of perfectsmile smile <lora:lora_perfectsmile_v1_from_v1_160:1>(Beautiful natural teeth, aligned bite teeth), aligned white teeth, human like teeth, (no teeth gap), celebrity-like teeth, healthy teeth with a perfect smile, not big incisor,good proportion teeth,good proportion smile,'
      }
    };

    // Start prediction
    const startResponse = await axios.post(
      'https://api.replicate.com/v1/predictions',
      predictionData,
      {
        headers: {
          'Authorization': `Token ${apiToken}`,
          'Content-Type': 'application/json'
        }
      }
    );

    const prediction = startResponse.data;
    console.log(`Prediction started with ID: ${prediction.id}`);

    // Poll for completion
    const maxAttempts = 60; // 5 minutes with 5-second intervals
    let attempts = 0;
    let completed = false;
    let result = null;

    while (!completed && attempts < maxAttempts) {
      await new Promise(resolve => setTimeout(resolve, 5000)); // Wait 5 seconds
      attempts++;

      try {
        const pollResponse = await axios.get(
          `https://api.replicate.com/v1/predictions/${prediction.id}`,
          {
            headers: {
              'Authorization': `Token ${apiToken}`
            }
          }
        );

        const pollData = pollResponse.data;
        console.log(`Poll attempt ${attempts}: Status = ${pollData.status}`);

        if (pollData.status === 'succeeded') {
          completed = true;
          result = pollData;
        } else if (pollData.status === 'failed') {
          return {
            statusCode: 500,
            headers,
            body: JSON.stringify({
              error: 'Prediction failed',
              details: pollData.error || 'Unknown error',
              logs: pollData.logs
            })
          };
        } else if (pollData.status === 'canceled') {
          return {
            statusCode: 500,
            headers,
            body: JSON.stringify({
              error: 'Prediction was canceled'
            })
          };
        }
      } catch (pollError) {
        console.error(`Poll error on attempt ${attempts}:`, pollError.message);
        if (attempts >= maxAttempts) {
          return {
            statusCode: 500,
            headers,
            body: JSON.stringify({
              error: 'Timeout waiting for prediction completion',
              prediction_id: prediction.id
            })
          };
        }
      }
    }

    if (!completed) {
      return {
        statusCode: 408,
        headers,
        body: JSON.stringify({
          error: 'Prediction timeout',
          prediction_id: prediction.id,
          message: 'Prediction is still processing. You can check the status using the prediction ID.'
        })
      };
    }

    // Return successful result
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        success: true,
        prediction_id: result.id,
        output: result.output,
        status: result.status,
        created_at: result.created_at,
        completed_at: result.completed_at,
        metrics: result.metrics
      })
    };

  } catch (error) {
    console.error('Lambda function error:', error);

    // Handle specific axios errors
    if (error.response) {
      const statusCode = error.response.status;
      const errorMessage = error.response.data?.error || error.response.data?.detail || 'API request failed';
      
      return {
        statusCode: statusCode >= 400 && statusCode < 500 ? statusCode : 500,
        headers,
        body: JSON.stringify({
          error: errorMessage,
          status_code: statusCode
        })
      };
    }

    // Handle network errors
    if (error.code === 'ENOTFOUND' || error.code === 'ECONNREFUSED') {
      return {
        statusCode: 503,
        headers,
        body: JSON.stringify({
          error: 'Service temporarily unavailable',
          message: 'Unable to connect to Replicate API'
        })
      };
    }

    // Generic error response
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({
        error: 'Internal server error',
        message: error.message
      })
    };
  }
}; 