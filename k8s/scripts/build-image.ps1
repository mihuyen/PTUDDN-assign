# Scripts hỗ trợ để build và deploy ứng dụng

# Build Docker image
Write-Host "Building Docker image..." -ForegroundColor Green
docker build -t k8s-demo-app:1.0.0 .

# Tag image for Docker Hub (thay YOUR_USERNAME bằng username của bạn)
# docker tag k8s-demo-app:1.0.0 YOUR_USERNAME/k8s-demo-app:1.0.0

# Push to Docker Hub (nếu cần)
# docker push YOUR_USERNAME/k8s-demo-app:1.0.0

Write-Host "Docker image built successfully!" -ForegroundColor Green
