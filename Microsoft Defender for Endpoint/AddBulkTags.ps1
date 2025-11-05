$disclaimer = @"
**Disclaimer:**
The author of this script provides it "as is" without any guarantees or warranties of any kind. 
By using this script, you acknowledge that you are solely responsible for any damage, data loss, or other issues that may arise from its execution. 
It is your responsibility to thoroughly test the script in a controlled environment before deploying it in a production setting. 
The author will not be held liable for any consequences resulting from the use of this script. Use at your own risk.
"@

Write-Host $disclaimer -ForegroundColor Yellow
Write-Host ""

# Ask for confirmation to proceed
$confirmation = Read-Host "Do you accept the disclaimer and wish to proceed? (Y/N)"

if ($confirmation -notmatch '^[Yy]$') {
    Write-Host "❌ Operation cancelled by user." -ForegroundColor Red
    exit
}

Write-Host "✅ Disclaimer accepted. Proceeding with execution..." -ForegroundColor Green
Write-Host ""

# ==============================
# Bulk Tag Machines in MDE
# ==============================

# --- Configuration ---
$tenantId     = "XYZ" 
$clientId     = "XYZ" 
$clientSecret = "XYZ"
$scope        = "https://api.securitycenter.microsoft.com/.default"

# --- Token Endpoint ---
$tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

# --- Get OAuth Token ---
$body = @{
    client_id     = $clientId
    client_secret = $clientSecret
    scope         = $scope
    grant_type    = "client_credentials"
}

$tokenResponse = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
$token = $tokenResponse.access_token

Write-Host "✅ Access token acquired successfully!"

# --- Import Machine IDs from CSV ---
# CSV should have a column named 'MachineId'
$machineIds = Import-Csv "$HOME/MachineIDs.csv" | Select-Object -ExpandProperty MachineId

# --- Prepare JSON body for tagging ---
$bodyTag = @{
    Value  = "API_Tag-Bulk"   # Change tag name as needed
    Action = "Add"
} | ConvertTo-Json

# --- Loop through each Machine ID and tag ---
foreach ($id in $machineIds) {
    $uri = "https://api.securitycenter.microsoft.com/api/machines/$id/tags"
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization  = "Bearer $token"
            "Content-Type" = "application/json"
        } -Body $bodyTag

        Write-Host "✅ Tagged machine: $id"
    }
    catch {
        Write-Host "❌ Failed to tag machine: $id. Error: $($_.Exception.Message)"
    }
}
