# 🦷 VeneerVision AI

A full-stack web application that uses AI to simulate dental veneers on uploaded smile images. Built with React frontend and Express backend, powered by the Replicate API.

## ✨ Features

### Core Functionality
- **AI-Powered Veneer Simulation**: Uses the `sourav-sarkar-doc32/smile-correct` model to generate realistic veneer previews
- **Multiple Image Generation**: Generate up to 4 different veneer variations (Dentist Mode)
- **Real-time Processing**: Live polling of AI model status with progress tracking
- **High-Quality Output**: Professional-grade veneer simulations

### User Experience
- **Interactive Smile Quiz**: Personalized shade recommendations based on preferences
- **Drag & Drop Upload**: Easy image upload with visual feedback
- **Camera Capture**: Built-in webcam support for instant photos
- **Side-by-Side Comparison**: Before/after image comparison
- **Image Navigation**: Browse through multiple generated variations
- **Download Options**: Individual image downloads and PDF reports

### Professional Features
- **Dentist Mode**: Enhanced features for dental professionals
- **Lead Capture**: Email collection for follow-up
- **PDF Reports**: Professional reports with patient information
- **Multiple Shade Options**: 5 different veneer shades available

## 🚀 Quick Start

### Prerequisites
- Node.js (v16 or higher)
- npm or yarn
- Replicate API token

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd veneer-vision-ai
   ```

2. **Set up environment variables**
   ```bash
   # Create .env file in backend directory
   cd backend
   echo "REPLICATE_API_TOKEN=your_replicate_token_here" > .env
   ```

3. **Install dependencies**
   ```bash
   # Backend dependencies
   cd backend
   npm install
   
   # Frontend dependencies
   cd ../frontend
   npm install
   ```

4. **Start the application**
   ```bash
   # Terminal 1: Start backend server
   cd backend
   npm start
   
   # Terminal 2: Start frontend server
   cd frontend
   npm start
   ```

5. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5001

## 🧪 Testing

### Manual Testing Checklist

#### Core Functionality
- [ ] **Image Upload**: Test drag & drop and file browser upload
- [ ] **Camera Capture**: Test webcam functionality
- [ ] **AI Processing**: Verify veneer generation works
- [ ] **Multiple Images**: Test dentist mode (4 images)
- [ ] **Error Handling**: Test with invalid images, no face detected
- [ ] **Navigation**: Test image browsing and comparison

#### User Interface
- [ ] **Smile Quiz**: Complete quiz and verify shade suggestions
- [ ] **Responsive Design**: Test on different screen sizes
- [ ] **Download Features**: Test image and PDF downloads
- [ ] **Dentist Mode**: Toggle and verify enhanced features

#### API Endpoints
- [ ] **POST /api/simulate**: Test veneer generation
- [ ] **POST /api/lead**: Test lead capture
- [ ] **Error Responses**: Test invalid requests

### Automated Testing

Run the test suite:
```bash
# Backend tests
cd backend
npm test

# Frontend tests
cd frontend
npm test
```

## 📁 Project Structure

```
veneer-vision-ai/
├── backend/
│   ├── index.js              # Express server with Replicate API integration
│   ├── package.json          # Backend dependencies
│   └── .env                  # Environment variables (create this)
├── frontend/
│   ├── src/
│   │   ├── App.js            # Main React component
│   │   ├── SmileQuiz.js      # Interactive quiz component
│   │   ├── DragDropUploader.js # File upload component
│   │   ├── PdfReport.js      # PDF generation utility
│   │   └── index.js          # React entry point
│   ├── public/
│   │   └── index.html        # HTML template
│   └── package.json          # Frontend dependencies
└── README.md                 # This file
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the backend directory:

```env
REPLICATE_API_TOKEN=your_replicate_api_token_here
PORT=5001
REPLICATE_MODEL_VERSION=4956c634b9aa976129f13166c713f8cf38bd337cd58c77925e8cd71d935d5696
```

### API Configuration

The app uses the following Replicate model:
- **Model**: `sourav-sarkar-doc32/smile-correct`
- **Version**: `4956c634b9aa976129f13166c713f8cf38bd337cd58c77925e8cd71d935d5696`
- **Timeout**: 4 minutes per prediction
- **Max Outputs**: 4 images (Dentist Mode)

## 🎨 Veneer Shades

The app supports 5 different veneer shades:

1. **Natural White** - Default natural appearance
2. **BL1 – Hollywood White** - Ultra bright celebrity white
3. **BL2 – Porcelain White** - Bright porcelain finish
4. **A1 – Slightly Warm White** - Subtle warm undertones
5. **A2 – Natural Yellow Tint** - Light natural yellow tint

## 🚨 Error Handling

The application handles various error scenarios:

- **Face Detection**: Clear error messages when no face is detected
- **Processing Timeout**: 4-minute timeout with user-friendly messages
- **Invalid Images**: Validation for supported image formats
- **Network Issues**: Connection error handling
- **API Failures**: Graceful degradation with retry logic

## 📊 Performance

- **Processing Time**: 2-4 minutes per image
- **Memory Usage**: Optimized for multiple concurrent predictions
- **Image Quality**: High-resolution output (up to 1024x1024)
- **Caching**: Efficient image loading and display

## 🔒 Security

- **CORS Configuration**: Restricted to localhost development
- **Input Validation**: Image format and size validation
- **API Token**: Secure environment variable storage
- **Error Sanitization**: No sensitive data in error messages

## 🚀 Deployment

### Production Build

```bash
# Build frontend for production
cd frontend
npm run build

# The build folder contains optimized static files
```

### Environment Setup

For production deployment:
1. Set up proper CORS origins
2. Configure environment variables
3. Set up reverse proxy (nginx recommended)
4. Enable HTTPS
5. Set up monitoring and logging

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For issues and questions:
1. Check the error logs in the browser console
2. Verify your Replicate API token is valid
3. Ensure all dependencies are installed
4. Check that both servers are running

## 🎯 Roadmap

- [ ] Real-time progress indicators
- [ ] Advanced image editing tools
- [ ] Patient management system
- [ ] Integration with dental practice software
- [ ] Mobile app version
- [ ] Advanced AI model options 