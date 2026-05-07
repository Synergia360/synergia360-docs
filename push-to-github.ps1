# Synergia360-v2 — GitHub push script
# Run from the synergia360-v2 folder:
#   cd C:\Users\shahi\_Projects\synergia360-v2
#   $env:GITHUB_TOKEN = "<personal-access-token-with-repo-scope>"
#   .\push-to-github.ps1

$token = $env:GITHUB_TOKEN
if (-not $token) {
    Write-Error "Set GITHUB_TOKEN to a PAT with repo scope (do not commit tokens)."
    exit 1
}
$org   = "synergia360"
$repo  = "synergia360-v2"

Write-Host "==> Creating GitHub repository $org/$repo ..." -ForegroundColor Cyan

$headers = @{
    Authorization = "token $token"
    Accept        = "application/vnd.github+json"
}
$body = @{
    name        = $repo
    description = "Synergia greenfield rebuild — multichannel marketplace management + 3PL platform"
    private     = $true
    auto_init   = $false
} | ConvertTo-Json

$response = Invoke-RestMethod `
    -Uri     "https://api.github.com/orgs/$org/repos" `
    -Method  POST `
    -Headers $headers `
    -Body    $body `
    -ContentType "application/json" `
    -ErrorAction SilentlyContinue

if ($response.clone_url) {
    Write-Host "==> Repo created: $($response.clone_url)" -ForegroundColor Green
} else {
    Write-Host "==> Repo may already exist or there was an API error — continuing with push." -ForegroundColor Yellow
}

$remoteUrl = "https://github.com/$org/$repo.git"

Write-Host "==> Initialising git ..." -ForegroundColor Cyan
git init
git checkout -b main

Write-Host "==> Staging files ..." -ForegroundColor Cyan
git add .

Write-Host "==> Committing ..." -ForegroundColor Cyan
git commit -m "Initial commit: Greenfield rebuild plan"

Write-Host "==> Setting remote and pushing ..." -ForegroundColor Cyan
git remote add origin $remoteUrl
git -c http.extraHeader="AUTHORIZATION: bearer $token" push -u origin main

Write-Host "==> Done! Repo is live at https://github.com/$org/$repo" -ForegroundColor Green
