const AWS = require('aws-sdk');
const axios = require('axios');

// Initialize AWS SDK
const s3 = new AWS.S3();

// Replicate API configuration
const REPLICATE_API_TOKEN = process.env.REPLICATE_API_TOKEN;
const REPLICATE_API_URL = 'https://api.replicate.com/v1/predictions';

exports.handler = async (event) => {
    console.log('S3 Event received:', JSON.stringify(event, null, 2));
    
    try {
        // Process each S3 record in the event
        for (const record of event.Records) {
            await processS3Record(record);
        }
        
        return {
            statusCode: 200,
            body: JSON.stringify({ message: 'Successfully processed S3 event' })
        };
        
    } catch (error) {
        console.error('Error processing S3 event:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ 
                error: 'Failed to process S3 event',
                details: error.message 
            })
        };
    }
};

async function processS3Record(record) {
    try {
        // Extract S3 information
        const s3Data = record.s3;
        const bucketName = s3Data.bucket.name;
        const objectKey = decodeURIComponent(s3Data.object.key.replace(/\+/g, ' '));
        const eventName = record.eventName;
        
        console.log('=== Processing S3 Record ===');
        console.log('Event Name:', eventName);
        console.log('Bucket Name:', bucketName);
        console.log('Object Key:', objectKey);
        
        // Only process PUT events
        if (!eventName.includes('ObjectCreated:Put')) {
            console.log('Skipping non-PUT event:', eventName);
            return;
        }
        
        // Build S3 object URL
        const s3ObjectUrl = `https://${bucketName}.s3.amazonaws.com/${objectKey}`;
        console.log('S3 Object URL:', s3ObjectUrl);
        
        // Call Replicate API
        const predictionResult = await callReplicateAPI(s3ObjectUrl);
        
        if (predictionResult && predictionResult.output && predictionResult.output.length > 0) {
            // Download the first prediction image
            const imageUrl = predictionResult.output[0];
            console.log('Prediction image URL:', imageUrl);
            
            // Download image and upload to S3
            await downloadAndUploadToS3(imageUrl, bucketName, objectKey);
            
            console.log('Successfully processed image:', objectKey);
        } else {
            console.error('No prediction output received from Replicate');
        }
        
    } catch (error) {
        console.error('Error processing S3 record:', error);
        throw error;
    }
}

async function callReplicateAPI(imageUrl) {
    try {
        console.log('Calling Replicate API with image URL:', imageUrl);
        
        // Check if API token is available
        if (!REPLICATE_API_TOKEN) {
            throw new Error('REPLICATE_API_TOKEN environment variable is not set');
        }
        
        // Create prediction request
        const predictionRequest = {
            version: "4956c634b9aa976129f13166c713f8cf38bd337cd58c77925e8cd71d935d5696",
            input: {
                image: imageUrl,
                prompt: "photo of perfectsmile smile <lora:lora_perfectsmile_v1_from_v1_160:1>(Beautiful natural teeth, aligned bite teeth), aligned white teeth, human like teeth, (no teeth gap), celebrity-like teeth, healthy teeth with a perfect smile, not big incisor,good proportion teeth,good proportion smile,"
            }
        };
        
        console.log('Prediction request:', JSON.stringify(predictionRequest, null, 2));
        
        // Start prediction
        const startResponse = await axios.post(REPLICATE_API_URL, predictionRequest, {
            headers: {
                'Authorization': `Token ${REPLICATE_API_TOKEN}`,
                'Content-Type': 'application/json'
            }
        });
        
        const prediction = startResponse.data;
        console.log('Prediction started:', prediction.id);
        
        // Poll for completion
        const result = await pollPrediction(prediction.id);
        return result;
        
    } catch (error) {
        console.error('Error calling Replicate API:', error.response?.data || error.message);
        throw new Error(`Replicate API error: ${error.response?.data?.error || error.message}`);
    }
}

async function pollPrediction(predictionId) {
    const maxAttempts = 60; // 5 minutes with 5-second intervals
    const pollInterval = 5000; // 5 seconds
    
    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
            console.log(`Polling prediction ${predictionId} (attempt ${attempt}/${maxAttempts})`);
            
            const response = await axios.get(`${REPLICATE_API_URL}/${predictionId}`, {
                headers: {
                    'Authorization': `Token ${REPLICATE_API_TOKEN}`
                }
            });
            
            const prediction = response.data;
            console.log('Prediction status:', prediction.status);
            
            if (prediction.status === 'succeeded') {
                console.log('Prediction completed successfully');
                return prediction;
            } else if (prediction.status === 'failed') {
                throw new Error(`Prediction failed: ${prediction.error || 'Unknown error'}`);
            } else if (prediction.status === 'canceled') {
                throw new Error('Prediction was canceled');
            }
            
            // Wait before next poll
            await new Promise(resolve => setTimeout(resolve, pollInterval));
            
        } catch (error) {
            console.error(`Error polling prediction (attempt ${attempt}):`, error.message);
            if (attempt === maxAttempts) {
                throw new Error(`Prediction polling timeout after ${maxAttempts} attempts`);
            }
            // Wait before retry
            await new Promise(resolve => setTimeout(resolve, pollInterval));
        }
    }
    
    throw new Error('Prediction polling timeout');
}

async function downloadAndUploadToS3(imageUrl, bucketName, originalKey) {
    try {
        console.log('Downloading image from:', imageUrl);
        
        // Download the image
        const imageResponse = await axios.get(imageUrl, {
            responseType: 'arraybuffer'
        });
        
        const imageBuffer = Buffer.from(imageResponse.data);
        console.log('Downloaded image size:', imageBuffer.length, 'bytes');
        
        // Generate output key
        const pathParts = originalKey.split('/');
        const filename = pathParts[pathParts.length - 1];
        const nameWithoutExt = filename.split('.')[0];
        const outputKey = `outputs/${nameWithoutExt}_veneer.png`;
        
        console.log('Uploading to S3:', `${bucketName}/${outputKey}`);
        
        // Upload to S3
        const uploadParams = {
            Bucket: bucketName,
            Key: outputKey,
            Body: imageBuffer,
            ContentType: 'image/png',
            Metadata: {
                'original-key': originalKey,
                'processed-at': new Date().toISOString(),
                'source': 'veneer-vision-ai'
            }
        };
        
        const uploadResult = await s3.upload(uploadParams).promise();
        console.log('Successfully uploaded to S3:', uploadResult.Location);
        
        return uploadResult;
        
    } catch (error) {
        console.error('Error downloading/uploading image:', error);
        throw new Error(`Image processing error: ${error.message}`);
    }
} 