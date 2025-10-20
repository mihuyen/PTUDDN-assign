# Chạy JMeter load test

param(
    [string]$Host = "localhost",
    [string]$Port = "30080"
)

Write-Host "Starting JMeter Load Test..." -ForegroundColor Green
Write-Host "Target: http://${Host}:${Port}" -ForegroundColor Yellow
Write-Host ""

# Kiểm tra JMeter đã cài đặt chưa
$jmeterPath = Get-Command jmeter -ErrorAction SilentlyContinue

if (-not $jmeterPath) {
    Write-Host "ERROR: JMeter not found!" -ForegroundColor Red
    Write-Host "Please install JMeter and add it to PATH" -ForegroundColor Yellow
    Write-Host "Download from: https://jmeter.apache.org/download_jmeter.cgi" -ForegroundColor Cyan
    exit 1
}

# Tạo thư mục results nếu chưa có
$resultsDir = "jmeter/results"
if (-not (Test-Path $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir | Out-Null
}

# Tạo timestamp cho file kết quả
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$resultFile = "$resultsDir/results-$timestamp.jtl"
$reportDir = "$resultsDir/report-$timestamp"

Write-Host "Running test..." -ForegroundColor Yellow
Write-Host ""

# Chạy JMeter test
jmeter -n `
    -t jmeter/load-test.jmx `
    -l $resultFile `
    -e -o $reportDir `
    -JHOST=$Host `
    -JPORT=$Port

Write-Host ""
Write-Host "Test completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Results saved to:" -ForegroundColor Cyan
Write-Host "  JTL File: $resultFile" -ForegroundColor White
Write-Host "  HTML Report: $reportDir/index.html" -ForegroundColor White
Write-Host ""
Write-Host "Opening report in browser..." -ForegroundColor Yellow
Start-Process "$reportDir/index.html"
