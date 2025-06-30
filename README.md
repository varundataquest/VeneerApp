# 🦷 VeneerVision AI

**VeneerVision AI** is a full-stack web application that uses AI to simulate dental veneers on uploaded smile images. Built with a React frontend and Express backend, powered by the Replicate API, it enables users to preview different veneer styles and shades in real time.

---

## 🚀 Features
- **AI-Powered Veneer Simulation**: Generate realistic veneer previews using the `sourav-sarkar-doc32/smile-correct` model via Replicate API.
- **Multiple Image Generation**: Dentist mode for up to 4 veneer variations per upload.
- **Smile Style Quiz**: Personalized recommendations based on user preferences.
- **Drag & Drop Upload + Camera Capture**: User-friendly image input.
- **PDF Report Generation**: Downloadable veneer preview reports.
- **Lead Capture**: Collects user info for follow-up.
- **Cloud-Ready Architecture**: Designed for easy deployment to AWS.

---

## 🏗️ Project Structure
```
veneer-vision-ai/
├── backend/      # Express.js API server
├── frontend/     # React.js client app
├── README.md     # This file
└── ...
```

---

## 💻 How to Run Locally

### 1. Clone the repository
```
git clone https://github.com/varundataquest/VeneerApp.git
cd VeneerApp
```

### 2. Install dependencies
```
cd backend && npm install
cd ../frontend && npm install
```

### 3. Set up environment variables
- Copy `.env.example` to `.env` in `backend/` and add your Replicate API key:
```
REPLICATE_API_TOKEN=your_replicate_api_token
```

### 4. Start the servers
- In one terminal:
```
cd backend && npm start
```
- In another terminal:
```
cd frontend && npm start
```
- Frontend: [http://localhost:3000](http://localhost:3000)
- Backend: [http://localhost:5001](http://localhost:5001)

---

## 🌥️ About the `cloud` Branch
This branch contains all code and configuration for cloud deployment, including:
- Cloud-ready `.gitignore` and environment management
- Modular backend/frontend for containerization
- AWS deployment instructions and IaC (if present)

---

## ☁️ AWS Cloud Integration Plan

### **1. Backend (Express API) on AWS Elastic Beanstalk**
- **Dockerize** the backend or use Node.js platform
- Deploy via Elastic Beanstalk CLI or AWS Console
- Use environment variables for secrets

### **2. Frontend (React) on AWS S3 + CloudFront**
- Build the React app: `npm run build`
- Upload `frontend/build/` to an S3 bucket
- Set up S3 static website hosting
- Distribute via CloudFront for global CDN

### **3. API Gateway + Lambda (Optional Serverless)**
- Refactor backend endpoints as AWS Lambda functions
- Use API Gateway to expose REST endpoints
- Store images in S3, trigger Lambda for processing

### **4. CI/CD with GitHub Actions & AWS CodePipeline**
- Set up GitHub Actions to build/test on push
- Deploy to Elastic Beanstalk/S3 automatically
- Use AWS CodePipeline for multi-stage deployments

### **5. Secrets & Monitoring**
- Store API keys in AWS Secrets Manager or SSM Parameter Store
- Enable CloudWatch for logs and alarms

### **6. (Optional) Database Integration**
- Use Amazon DynamoDB or RDS for persistent lead storage

---

## 📝 Example AWS Deployment Steps

### **Elastic Beanstalk (Backend)**
1. Install EB CLI: `pip install awsebcli`
2. Initialize: `eb init -p node.js veneer-vision-backend`
3. Deploy: `eb create veneer-backend-env`
4. Set env vars: `eb setenv REPLICATE_API_TOKEN=...`

### **S3 + CloudFront (Frontend)**
1. Build: `cd frontend && npm run build`
2. Create S3 bucket & enable static hosting
3. Upload `build/` contents
4. Set up CloudFront distribution

### **Serverless (Optional)**
- Use AWS SAM or Serverless Framework to deploy Lambda/API Gateway

---

## 📚 Resume/Portfolio Highlights
- **Cloud-Native Full Stack App**: Designed for AWS deployment
- **CI/CD Automation**: GitHub Actions + AWS
- **Serverless & Containerization**: Ready for Lambda, ECS, or Beanstalk
- **Modern Frontend/Backend**: React, Express, RESTful APIs
- **AI/ML Integration**: Replicate API for real-world inference

---

## 🤝 Contributing
Pull requests welcome! For major changes, open an issue first.

---

## 📄 License
MIT

---

## 🙋 FAQ
- **Q: How do I deploy to AWS?**
  See the AWS Cloud Integration Plan above.
- **Q: How do I run locally?**
  See the steps above.
- **Q: What is the `cloud` branch?**
  The branch for cloud deployment and AWS integration.

---

**Built by [varundataquest](https://github.com/varundataquest) — Cloud Engineer Portfolio Project** 