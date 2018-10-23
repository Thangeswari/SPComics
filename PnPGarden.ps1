#Ensure Latest SharePointPnPPowerShell* is installed
Install-Module -Name "SharePointPnPPowerShellOnline"

#Connect to your SharePoint Site.Replace with your url
$siteurl = "https://xxx.sharepoint.com/sites/dev" 

Connect-PnPOnline –Url $siteUrl –Credentials (Get-Credential)

#Create a Garden subsite
New-PnPWeb -Title "GardenPnP" -Url "GardenPnP" -Description "Garden Subsite PnP" -Template "STS#0"

#Update the URL
$gardenUrl=$siteUrl+"/GardenPnP"
Connect-PnPOnline –Url $gardenUrl –Credentials (Get-Credential)
(Get-PnPContext).Url

#Create a List Named Fruits
New-PnPList -Title "Fruits" -Template GenericList

#Create a column named Location of Text or GeoLocation type
Add-PnPField -List "Fruits" -DisplayName "Location" -InternalName "Location" -Type Text -AddToDefaultView

#Add 5 items to Fruits List
$fruits="Apple","Orange","Mango","Kiwi","Pomogranate"
$location="Washington"
foreach ($item in $fruits)
{    
    $newItem = Add-PnPListItem -List Fruits
    Set-PnPListItem -List "Fruits"  -Identity $newItem -Values @{"Title"="$($item)";"Location"="$($location)";}  
}

#Read the Fruit Details.
Get-PnPListItem -List "Fruits"

#Find Apple
$appleItem=Get-PnPListItem -List Fruits -Query "<View><Query><Where><Eq><FieldRef Name='Title'/><Value 
    Type='Text'>Apple</Value></Eq></Where></Query></View>"

#Update the Place for Apple from Washington to Australia.
Set-PnPListItem -List "Fruits" -Identity $appleItem -Values @{"Title"="Apple";"Location"="Australia"}

#Find Mango
$mangoItem=Get-PnPListItem -List Fruits -Query "<View><Query><Where><Eq><FieldRef Name='Title'/><Value 
    Type='Text'>Mango</Value></Eq></Where></Query></View>"

#Delete Mango
Remove-PnPListItem -List Fruits -Identity $mangoItem

