#Download Sharepoint online client components
#Specify your tenant admin and site URL
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

#JSON for custom list
#https://docs.microsoft.com/en-us/sharepoint/dev/declarative-customization/column-formatting
<#Create a new list if not already created
$listInfo = New-Object Microsoft.SharePoint.Client.ListCreationInformation
$listInfo.Title="PSJSON"
$listInfo.TemplateType=[Microsoft.SharePoint.Client.ListTemplateType]::GenericList
$psListJSON=$context.Web.Lists.Add($listInfo)
$psListJSON.Description = "JSON List through code"
$psListJSON.Update()
$Context.ExecuteQuery()
#>

$listName="PSJSON"
$psListJSON = $context.Web.Lists.GetByTitle($listName)
$context.Load($psListJSON)
$Context.ExecuteQuery()


<#Create a new Display Field for testing
$fieldType="Text"
$fieldName="CSSDisp1"
$fieldXml="<Field Type='"+$fieldType +"' DisplayName='"+$fieldName +"' />";
$CSS1Field=$psListJSON.Fields.AddFieldAsXml($fieldXml, $true, [Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldInternalNameHint);
$Context.ExecuteQuery()
#>
#Background Image
$fieldName="Title"
$CSSDisp1Field=$psListJSON.Fields.GetByInternalNameOrTitle($fieldName)
$Context.Load($CSSDisp1Field)
$Context.ExecuteQuery()
$CSSCode=@"
{
   "elmType": "div",
   "txtContent": "@currentField",
    "style": {
      "color":"=if([`$Title] <= 3, 'blue', 'violet'"     
    }
}
"@

$CSSDisp1Field.CustomFormatter=$CSSCode;
$CSSDisp1Field.Update()
$Context.ExecuteQuery()

