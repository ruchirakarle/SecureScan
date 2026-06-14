# Run from root of SecureScan after terraform apply

$backendIp = terraform -chdir=terraform output -raw backend_ip
$bucketName = terraform -chdir=terraform output -raw frontend_bucket_name
$frontendUrl = terraform -chdir=terraform output -raw frontend_website_url

Write-Host "Backend IP: $backendIp"

"REACT_APP_API_URL=http://${backendIp}:3001" | Out-File -FilePath frontend\.env.production -Encoding utf8 -NoNewline

Set-Location frontend
npm install
npm run build
aws s3 sync build/ s3://$bucketName --delete
Set-Location ..

Write-Host "Deployed! Visit: $frontendUrl"