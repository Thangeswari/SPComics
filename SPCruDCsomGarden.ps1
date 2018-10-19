#Connect to your SharePoint Online site with your credentials
#Download Sharepoint online client components
#Specify tenant admin and site URL
$User = "admin@xxx.onmicrosoft.com"
$SiteURL = "https://xxx.sharepoint.com/sites/dev"
#Add references to SharePoint client assemblies 
$spPath="C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\"
Add-Type -Path ($spPath+"Microsoft.SharePoint.Client.dll")
Add-Type -Path ($spPath+"Microsoft.SharePoint.Client.Runtime.dll")
Add-Type -Path ($spPath+"Microsoft.SharePoint.Client.Search.dll")
Add-Type -Path ($spPath+"Microsoft.SharePoint.Client.Taxonomy.dll")
Add-Type -Path ($spPath+"Microsoft.SharePoint.Client.Publishing.dll")
Add-Type -Path ($spPath+"Microsoft.SharePoint.Client.UserProfiles.dll")
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User,$Password)
#Bind to site collection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Context.Credentials = $Creds

#Create a Garden subsite
$creationInfo = new-object Microsoft.SharePoint.Client.WebCreationInformation
$creationInfo.Title = "Garden Subsite1"
$creationInfo.Url = "GardenCsom"
$newDevWeb = $Context.Web.Webs.Add($creationInfo)
$Context.ExecuteQuery()

#Update the URL
$gardenUrl=$SiteURL+"/GardenCsom"
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($gardenUrl)
$Context.Credentials = $Creds


#Create a List Named Fruits
$listInfo = New-Object Microsoft.SharePoint.Client.ListCreationInformation
$listInfo.Title="Fruits"
$listInfo.TemplateType=[Microsoft.SharePoint.Client.ListTemplateType]::GenericList
$psList=$context.Web.Lists.Add($listInfo)
$psList.Description = "Fruits List through code"
$psList.Update()
$Context.ExecuteQuery()

#Create a column named Location.
$psListFruits = $context.Web.Lists.GetByTitle("Fruits")
$context.Load($psListFruits)
$Context.ExecuteQuery()

$fieldType="Text"
$fieldName="Location"
$fieldXml="<Field Type='"+$fieldType +"' DisplayName='"+$fieldName +"' />";
$fruitField=$psListFruits.Fields.AddFieldAsXml($fieldXml, $true, [Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldInternalNameHint);
$Context.ExecuteQuery()

#Add 5 items to Fruits List
$fruits="Apple","Orange","Mango","Kiwi","Pomogranate"
$location="Washington"
foreach ($item in $fruits)
{
    $fruitInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
    $fruitItem=$psListFruits.AddItem($fruitInfo)
    $fruitItem["Title"] = $item
    $fruitItem["Location"] = $location
    $fruitItem.Update()    
}
$Context.ExecuteQuery() 


#Read the Fruit Details.
$camlQ= [Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery()
$listItems=$psListFruits.GetItems($camlQ)
$Context.Load($listItems)
$Context.ExecuteQuery()

$allItems=@()
foreach ($item in $listItems)
    {   $Context.Load($item)
        $Context.ExecuteQuery()
        $allItems+=$item.FieldValues            
    }
    Write-Host "ID"  "Title" "Location"
$allItems|%{Write-Host $_["ID"] $_["Title"] $_["Location"]}

#Find Apple
$fieldName="Title"
$fieldValue="Apple"
$sb = [System.Text.StringBuilder]::new()
[void]$sb.Append( '<View><Query>' )
[void]$sb.AppendLine("<FieldRef Name='"+$fieldName+"'/>");
[void]$sb.AppendLine("<Where>");
[void]$sb.AppendLine("<Eq><FieldRef Name='"+$fieldName+"' />");
[void]$sb.AppendLine("<Value Type='Text'>"+$fieldValue+"</Value>");
[void]$sb.AppendLine("</Where>");
[void]$sb.AppendLine("</Eq>");
[void]$sb.AppendLine("</Query><RowLimit>100</RowLimit></View>");
$sb.ToString()
$camlQ= New-Object Microsoft.SharePoint.Client.CamlQuery
$camlQ.ViewXml=$sb.ToString()
$items = $psListFruits.GetItems($camlQ); 
$context.Load($items); 
$context.ExecuteQuery();
$appleItem=$items[0] 

#Update the Place for Apple from Washington to Australia.
$appleItem["Location"]="Australia"
$appleItem.Update()
$Context.ExecuteQuery()

#Find Mango
$fieldName="Title"
$fieldValue="Mango"
$sb = [System.Text.StringBuilder]::new()
[void]$sb.Append( '<View><Query>' )
[void]$sb.AppendLine("<FieldRef Name='"+$fieldName+"'/>");
[void]$sb.AppendLine("<Where>");
[void]$sb.AppendLine("<Eq><FieldRef Name='"+$fieldName+"' />");
[void]$sb.AppendLine("<Value Type='Text'>"+$fieldValue+"</Value>");
[void]$sb.AppendLine("</Where>");
[void]$sb.AppendLine("</Eq>");
[void]$sb.AppendLine("</Query><RowLimit>100</RowLimit></View>");
$sb.ToString()
$camlQ= New-Object Microsoft.SharePoint.Client.CamlQuery
$camlQ.ViewXml=$sb.ToString()
$items = $psListFruits.GetItems($camlQ); 
$context.Load($items); 
$context.ExecuteQuery(); 

$mangoItem=$items[0]

#Delete Mango
$mangoid=$mangoItem.Recycle()
$Context.ExecuteQuery()