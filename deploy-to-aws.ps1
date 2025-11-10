# AWS Deployment Script for Angular + Fastify Application
# This script automates the deployment to AWS ECR and ECS

param(
    [Parameter(Mandatory=$false)]
    [string]$Region = "us-east-1",
    
    [Parameter(Mandatory=$false)]
    [string]$RepositoryName = "angular-fastify-app",
    
    [Parameter(Mandatory=$false)]
    [string]$ClusterName = "angular-fastify-cluster",
    
    [Parameter(Mandatory=$false)]
    [string]$ServiceName = "angular-fastify-service",
    
    [Parameter(Mandatory=$false)]
    [string]$ImageTag = "latest"
)

Write-Host "🚀 AWS Deployment Script - Angular + Fastify" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "📋 Checking prerequisites..." -ForegroundColor Yellow

# Check AWS CLI
try {
    $awsVersion = aws --version 2>&1
    Write-Host "✓ AWS CLI installed: $awsVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ AWS CLI not found. Please install AWS CLI first." -ForegroundColor Red
    Write-Host "Download from: https://aws.amazon.com/cli/" -ForegroundColor Yellow
    exit 1
}

# Check Docker
try {
    docker --version | Out-Null
    Write-Host "✓ Docker is installed" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker not found. Please install Docker Desktop." -ForegroundColor Red
    exit 1
}

# Check AWS credentials
try {
    $awsAccount = aws sts get-caller-identity --query Account --output text 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ AWS credentials configured (Account: $awsAccount)" -ForegroundColor Green
    } else {
        throw "Not configured"
    }
} catch {
    Write-Host "✗ AWS credentials not configured. Run 'aws configure'" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📦 AWS Account ID: $awsAccount" -ForegroundColor Cyan
Write-Host "🌍 Region: $Region" -ForegroundColor Cyan
Write-Host "📦 Repository: $RepositoryName" -ForegroundColor Cyan
Write-Host ""

# Deployment options
Write-Host "Select deployment option:" -ForegroundColor Cyan
Write-Host "1. Build and push to ECR only" -ForegroundColor White
Write-Host "2. Build, push to ECR, and deploy to ECS" -ForegroundColor White
Write-Host "3. Build, push to ECR, and deploy to Elastic Beanstalk" -ForegroundColor White
Write-Host "4. Exit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-4)"

if ($choice -eq "4") {
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    exit 0
}

# Step 1: Build Docker image
Write-Host ""
Write-Host "🔨 Step 1: Building Docker image..." -ForegroundColor Yellow
Write-Host ""

docker build -t ${RepositoryName}:${ImageTag} .

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Docker build failed" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Docker image built successfully" -ForegroundColor Green

# Step 2: Create ECR repository if not exists
Write-Host ""
Write-Host "📦 Step 2: Checking ECR repository..." -ForegroundColor Yellow

$repoExists = aws ecr describe-repositories --repository-names $RepositoryName --region $Region 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Creating ECR repository..." -ForegroundColor Yellow
    aws ecr create-repository --repository-name $RepositoryName --region $Region | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ ECR repository created" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to create ECR repository" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✓ ECR repository exists" -ForegroundColor Green
}

# Step 3: Authenticate Docker to ECR
Write-Host ""
Write-Host "🔐 Step 3: Authenticating Docker to ECR..." -ForegroundColor Yellow

$ecrLogin = aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin "${awsAccount}.dkr.ecr.${Region}.amazonaws.com" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Docker authenticated to ECR" -ForegroundColor Green
} else {
    Write-Host "✗ ECR authentication failed" -ForegroundColor Red
    exit 1
}

# Step 4: Tag image for ECR
Write-Host ""
Write-Host "🏷️  Step 4: Tagging image for ECR..." -ForegroundColor Yellow

$ecrImageUri = "${awsAccount}.dkr.ecr.${Region}.amazonaws.com/${RepositoryName}:${ImageTag}"
docker tag ${RepositoryName}:${ImageTag} $ecrImageUri

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Image tagged: $ecrImageUri" -ForegroundColor Green
} else {
    Write-Host "✗ Image tagging failed" -ForegroundColor Red
    exit 1
}

# Step 5: Push image to ECR
Write-Host ""
Write-Host "⬆️  Step 5: Pushing image to ECR..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Gray

docker push $ecrImageUri

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Image pushed to ECR successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Image push failed" -ForegroundColor Red
    exit 1
}

# Get image digest
$imageDigest = aws ecr describe-images --repository-name $RepositoryName --region $Region --query 'imageDetails[0].imageDigest' --output text

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✓ Image successfully pushed to ECR!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Image URI: $ecrImageUri" -ForegroundColor White
Write-Host "Digest: $imageDigest" -ForegroundColor White
Write-Host ""

# Continue with deployment based on choice
if ($choice -eq "1") {
    Write-Host "✓ Deployment complete! Image is ready in ECR." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Use this image URI in your ECS task definition" -ForegroundColor White
    Write-Host "2. Or deploy to Elastic Beanstalk using Dockerrun.aws.json" -ForegroundColor White
    Write-Host "3. See AWS-DEPLOYMENT.md for detailed instructions" -ForegroundColor White
    exit 0
}

if ($choice -eq "2") {
    Write-Host ""
    Write-Host "🚀 Deploying to ECS..." -ForegroundColor Yellow
    Write-Host ""
    
    # Check if cluster exists
    $clusterExists = aws ecs describe-clusters --clusters $ClusterName --region $Region --query 'clusters[0].status' --output text 2>&1
    
    if ($clusterExists -ne "ACTIVE") {
        Write-Host "Creating ECS cluster..." -ForegroundColor Yellow
        aws ecs create-cluster --cluster-name $ClusterName --region $Region | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ ECS cluster created" -ForegroundColor Green
        } else {
            Write-Host "✗ Failed to create ECS cluster" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "✓ ECS cluster exists" -ForegroundColor Green
    }
    
    # Check if task definition exists
    Write-Host ""
    Write-Host "Registering task definition..." -ForegroundColor Yellow
    Write-Host "⚠ Note: You need to create aws-ecs-task-definition.json first" -ForegroundColor Yellow
    Write-Host "See AWS-DEPLOYMENT.md for template" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "✓ ECS deployment prepared" -ForegroundColor Green
    Write-Host "Run manually: aws ecs register-task-definition --cli-input-json file://aws-ecs-task-definition.json" -ForegroundColor White
}

if ($choice -eq "3") {
    Write-Host ""
    Write-Host "🚀 Preparing Elastic Beanstalk deployment..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "✓ Image ready for Elastic Beanstalk" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Create Dockerrun.aws.json with the image URI above" -ForegroundColor White
    Write-Host "2. Run: eb init -p docker ${RepositoryName} --region ${Region}" -ForegroundColor White
    Write-Host "3. Run: eb create angular-fastify-env" -ForegroundColor White
    Write-Host "4. Run: eb deploy" -ForegroundColor White
    Write-Host ""
    Write-Host "See AWS-DEPLOYMENT.md for detailed instructions" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✓ AWS Deployment Script Complete!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "📚 For detailed deployment instructions, see:" -ForegroundColor Cyan
Write-Host "   AWS-DEPLOYMENT.md" -ForegroundColor White
Write-Host ""
