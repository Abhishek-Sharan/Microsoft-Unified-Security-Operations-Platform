$subscriptionId = "080eb798-68a7-4bfb-bc80-935092b1c7e7"
$resourceGroup = "sec-siem-rg"
$workspaceName = "sec-sentinel"
$apiVersion = "2025-09-01"

$uri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.OperationalInsights/workspaces/$workspaceName/providers/Microsoft.SecurityInsights/incidents?api-version=$apiVersion"

$response = Invoke-AzRestMethod -Uri $uri -Method GET
$incidents = ($response.Content | ConvertFrom-Json).value

$incidents | Select-Object @{Name='IncidentNumber';Expression={$_.properties.incidentNumber}},
                            @{Name='Title';Expression={$_.properties.title}},
                            @{Name='Severity';Expression={$_.properties.severity}},
                            @{Name='Status';Expression={$_.properties.status}},
                            @{Name='CreatedTimeUtc';Expression={$_.properties.createdTimeUtc}},
                            @{Name='Owner';Expression={$_.properties.owner.assignedTo}} |
    Format-Table -AutoSize
