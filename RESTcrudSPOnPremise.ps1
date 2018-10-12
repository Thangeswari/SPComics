#CRUD Series 

#Read
function Read-SPOnPremiseObject($targetSite,$UserName,$restUrl){
$targetSiteUri = [System.Uri]$targetSite
$credentials = Get-Credential -UserName $UserName -Message "Enter Password"
# Set  Header
$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$webSession.Headers.Add("Accept", "application/json;odata=verbose")
$webSession.Headers.Add("X-FORMS_BASED_AUTH_ACCEPTED", "f")
$webSession.Credentials=$credentials
$fullUrl=$targetSite+$restUrl
$results=   Invoke-RestMethod -Uri $fullUrl -Headers $headers -Method Get -Body $null -WebSession $webSession -ContentType "application/json;odata=verbose"

Write-Host "Invoking results from Url" $fullUrl
Write-Host $results
return $results  
}

#Create
function Create-SPOnPremiseObject($targetSite,$UserName,$restUrl,$data){
$targetSiteUri = [System.Uri]$targetSite
$credentials = Get-Credential -UserName $UserName -Message "Enter Password"
# Set  Header
$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$webSession.Headers.Add("Accept", "application/json;odata=verbose")
$webSession.Headers.Add("X-FORMS_BASED_AUTH_ACCEPTED", "f")
$webSession.Credentials=$credentials
#Getting Form Digest
$contextUrl=$targetSite + "/_api/contextinfo"
$result=Invoke-RestMethod -Method Post -Uri $contextUrl -Header $headers  -WebSession $webSession -Body $null
$formDigest = $result.d.GetContextWebInformation.FormDigestValue
$headers = @{accept = "application/json;odata=verbose"}
$headers.Add("X-RequestDigest", $formDigest);
#$headers.Add("Content-Type","application/json;odata=verbose");
$fullUrl=$targetSite+$restUrl
Write-Host "Creating Object..." for $fullUrl "with header" $headers.Values
$response=Invoke-RestMethod -Uri $fullUrl -Headers $headers -Method Post -Body $data -WebSession $webSession -ContentType "application/json;odata=verbose"
Write-Host "Creating Object...";Write-Host $response
return $response   
}

#Update
function Update-SPOnPremiseObject($targetSite,$UserName,$restUrl,$data,$etag,$putonly){
$targetSiteUri = [System.Uri]$targetSite
$credentials = Get-Credential -UserName $UserName -Message "Enter Password"
# Set  Header
$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$webSession.Headers.Add("Accept", "application/json;odata=verbose")
$webSession.Headers.Add("X-FORMS_BASED_AUTH_ACCEPTED", "f")
$webSession.Credentials=$credentials

#Getting Form Digest
#Post request to get FormDigest value
$contextUrl=$targetSite + "/_api/contextinfo"
$result=Invoke-RestMethod -Method Post -Uri $contextUrl -Header $headers  -WebSession $webSession -Body $null
$formDigest = $result.d.GetContextWebInformation.FormDigestValue
$headers = @{accept = "application/json; odata=verbose"}
$headers.Add("X-RequestDigest", $formDigest);
if($putonly -eq "true"){
$headers.Add("X-HTTP-Method", "PUT");
}else{
$headers.Add("X-HTTP-Method", "MERGE");
}
if($etag -ne $null){
$headers.Add("IF-MATCH", $etag); 
}

$fullUrl=$targetSite+$restUrl
$response=Invoke-RestMethod -Uri $fullUrl -Headers $headers -Method Post -Body $data -WebSession $webSession -ContentType "application/json;odata=verbose"

Write-Host "Updating Object..."
Write-Host $response
return $response
}

#Delete
function Delete-SPOnPremiseObject($targetSite,$UserName,$restUrl){
$targetSiteUri = [System.Uri]$targetSite
$credentials = Get-Credential -UserName $UserName -Message "Enter Password"
# Set  Header
$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$webSession.Headers.Add("Accept", "application/json;odata=verbose")
$webSession.Headers.Add("X-FORMS_BASED_AUTH_ACCEPTED", "f")
$webSession.Credentials=$credentials

#Getting Form Digest
#Post request to get FormDigest value
$contextUrl=$targetSite + "/_api/contextinfo"
$result=Invoke-RestMethod -Method Post -Uri $contextUrl -Header $headers  -WebSession $webSession -Body $null
$formDigest = $result.d.GetContextWebInformation.FormDigestValue
$headers = @{accept = "application/json; odata=verbose"}
$headers.Add("X-RequestDigest", $formDigest);
$headers.Add("X-HTTP-Method", "DELETE");
$headers.Add("IF-MATCH", "*"); 

$fullUrl=$targetSite+$restUrl
$response=Invoke-RestMethod -Uri $fullUrl -Headers $headers -Method Post  -WebSession $webSession -ContentType "application/json;odata=verbose"

Write-Host "Deleting Object..."
Write-Host $response
return $response
}

