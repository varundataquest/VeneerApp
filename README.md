# VeneerVision AI 🦷✨

A full-stack AI-powered dental veneer simulation application that allows users to visualize how dental veneers would look on their smile using advanced AI technology.

## 🚀 Features

- **AI-Powered Veneer Simulation**: Uses Replicate API with the `sourav-sarkar-doc32/smile-correct` model
- **Multiple Image Generation**: Generate up to 4 different veneer variations (dentist mode)
- **Image Upload & Camera Capture**: Drag-and-drop upload or direct camera capture
- **Interactive Comparison**: Side-by-side before/after comparison
- **Smile Style Quiz**: Personalized veneer recommendations
- **Lead Capture**: Collect patient information
- **PDF Report Generation**: Download detailed reports
- **Responsive Design**: Works on desktop and mobile devices

## 🏗️ Architecture

- **Frontend**: React.js with modern UI components
- **Backend**: Express.js API server
- **AI Integration**: Replicate API for veneer simulation
- **File Handling**: Image processing and PDF generation

## 🌩 Cloud Migration Plan

This project is now being migrated to AWS using a serverless architecture. The `cloud` branch contains the Infrastructure as Code (IaC) and deployment tools for:

- **AWS Lambda**: Serverless backend functions
- **API Gateway**: RESTful API endpoints
- **S3**: Static frontend hosting and file storage
- **CloudFront**: CDN for global content delivery
- **DynamoDB**: NoSQL database for user data
- **CloudWatch**: Monitoring and logging

The cloud deployment will provide:
- Auto-scaling capabilities
- Reduced operational overhead
- Global availability
- Cost optimization
- Enhanced security

## 🛠️ Local Development

### Prerequisites

- Node.js (v16 or higher)
- npm or yarn
- Replicate API token

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd veneer-vision-ai
   ```

2. **Install dependencies**
   ```bash
   # Backend
   cd backend
   npm install
   
   # Frontend
   cd ../frontend
   npm install
   ```

3. **Environment Configuration**
   ```bash
   # Backend
   cd backend
   cp .env.example .env
   # Edit .env with your Replicate API token
   
   # Frontend
   cd ../frontend
   cp .env.example .env
   # Edit .env with your API URL
   ```

4. **Start the servers**
   ```bash
   # Backend (Terminal 1)
   cd backend
   npm start
   
   # Frontend (Terminal 2)
   cd frontend
   npm start
   ```

5. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5001

## 📁 Project Structure

```
veneer-vision-ai/
├── backend/                 # Express.js API server
│   ├── index.js            # Main server file
│   ├── package.json        # Backend dependencies
│   └── .env.example        # Environment variables template
├── frontend/               # React.js web application
│   ├── src/                # Source code
│   │   ├── App.js          # Main React component
│   │   ├── DragDropUploader.js    # Image upload component
│   │   ├── SmileQuiz.js           # Quiz component
│   │   └── PdfReport.js           # PDF generation
│   ├── public/             # Static assets
│   └── .env.example        # Environment variables template
├── .gitignore              # Git ignore rules
└── README.md               # Project documentation
```

## 🔧 Configuration

### Environment Variables

**Backend (.env)**
- `REPLICATE_API_TOKEN`: Your Replicate API token
- `PORT`: Server port (default: 5001)
- `REPLICATE_MODEL_VERSION`: AI model version (optional)

**Frontend (.env)**
- `REACT_APP_API_URL`: Backend API URL

## 🚀 Deployment

### Local Development
```bash
# Start both servers
npm run dev
```

### Production Build
```bash
# Frontend
cd frontend
npm run build

# Backend
cd backend
npm start
```

## 📊 API Endpoints

- `POST /api/simulate`: Generate veneer simulation
- `GET /api/health`: Health check endpoint

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Contact the development team

## 🔮 Roadmap

- [ ] AWS Cloud deployment
- [ ] User authentication
- [ ] Advanced analytics
- [ ] Mobile app development
- [ ] Integration with dental practice management systems 