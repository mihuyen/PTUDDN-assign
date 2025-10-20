# Maven wrapper script
# This script will download Maven if needed

# Check if Maven is available
$mvnCmd = Get-Command mvn -ErrorAction SilentlyContinue

if ($mvnCmd) {
    Write-Host "Using Maven from PATH: $($mvnCmd.Source)" -ForegroundColor Green
    & mvn $args
} else {
    Write-Host "Maven not found in PATH!" -ForegroundColor Red
    Write-Host "Please install Maven from: https://maven.apache.org/download.cgi" -ForegroundColor Yellow
    Write-Host "Or use Maven Wrapper (mvnw) if available" -ForegroundColor Yellow
    exit 1
}
