# Quick Start Script for Angular + Fastify Deployment

Write-Host "🚀 Angular + Fastify Deployment" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
try {
    docker --version | Out-Null
    Write-Host "✓ Docker is installed" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker is not installed or not running" -ForegroundColor Red
    Write-Host "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Check if docker-compose is available
try {
    docker-compose --version | Out-Null
    Write-Host "✓ Docker Compose is available" -ForegroundColor Green
} catch {
    Write-Host "⚠ Docker Compose not found, will use Docker commands instead" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Select an option:" -ForegroundColor Cyan
Write-Host "1. Build and run (Docker Compose)" -ForegroundColor White
Write-Host "2. Build and run (Docker commands)" -ForegroundColor White
Write-Host "3. Stop and remove container" -ForegroundColor White
Write-Host "4. View logs" -ForegroundColor White
Write-Host "5. Clean up (remove images and containers)" -ForegroundColor White
Write-Host "6. Exit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-6)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Building and starting with Docker Compose..." -ForegroundColor Cyan
        docker-compose up --build -d
        Write-Host ""
        Write-Host "✓ Application is running!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Access your application at:" -ForegroundColor Cyan
        Write-Host "  Frontend: http://localhost:3000" -ForegroundColor White
        Write-Host "  API Health: http://localhost:3000/api/health" -ForegroundColor White
        Write-Host ""
        Write-Host "View logs with: docker-compose logs -f" -ForegroundColor Yellow
    }
    "2" {
        Write-Host ""
        Write-Host "Building Docker image..." -ForegroundColor Cyan
        docker build -t angular-fastify-app .
        
        Write-Host ""
        Write-Host "Starting container..." -ForegroundColor Cyan
        docker run -d -p 3000:3000 --name angular-fastify-app angular-fastify-app
        
        Write-Host ""
        Write-Host "✓ Application is running!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Access your application at:" -ForegroundColor Cyan
        Write-Host "  Frontend: http://localhost:3000" -ForegroundColor White
        Write-Host "  API Health: http://localhost:3000/api/health" -ForegroundColor White
        Write-Host ""
        Write-Host "View logs with: docker logs -f angular-fastify-app" -ForegroundColor Yellow
    }
    "3" {
        Write-Host ""
        Write-Host "Stopping and removing container..." -ForegroundColor Cyan
        try {
            docker-compose down
        } catch {
            docker stop angular-fastify-app
            docker rm angular-fastify-app
        }
        Write-Host "✓ Container stopped and removed" -ForegroundColor Green
    }
    "4" {
        Write-Host ""
        Write-Host "Showing logs (Press Ctrl+C to exit)..." -ForegroundColor Cyan
        try {
            docker-compose logs -f
        } catch {
            docker logs -f angular-fastify-app
        }
    }
    "5" {
        Write-Host ""
        Write-Host "⚠ This will remove all containers and images" -ForegroundColor Yellow
        $confirm = Read-Host "Are you sure? (yes/no)"
        if ($confirm -eq "yes") {
            Write-Host "Cleaning up..." -ForegroundColor Cyan
            docker-compose down
            docker rmi angular-fastify-app
            docker system prune -f
            Write-Host "✓ Cleanup complete" -ForegroundColor Green
        } else {
            Write-Host "Cleanup cancelled" -ForegroundColor Yellow
        }
    }
    "6" {
        Write-Host "Goodbye! 👋" -ForegroundColor Cyan
        exit 0
    }
    default {
        Write-Host "Invalid choice. Please run the script again." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
