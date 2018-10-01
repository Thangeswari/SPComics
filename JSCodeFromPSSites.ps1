function CreateJSScriptSiteDetails($SiteURL,$User,$loadObject,$SpProperty,$propertyName,$MultiResult,$itemProperty){

#Download Sharepoint online client components

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

$enc = [system.Text.Encoding]::UTF8

$sb = [System.Text.StringBuilder]::new()
[void]$sb.Append( '<script type="text/ecmascript" language="ecmascript">' )
[void]$sb.AppendLine("var site;");
[void]$sb.AppendLine("var items;var item;var info;");
[void]$sb.AppendLine("var clientContext;");
[void]$sb.AppendLine("function getSite"+$loadObject+"(){");
[void]$sb.AppendLine("this.clientContext = new SP.ClientContext.get_current();");
[void]$sb.AppendLine("if (this.clientContext != undefined && this.clientContext != null) {");
[void]$sb.AppendLine("this.site= clientContext.get_site();");
if($MultiResult -eq $true){
[void]$sb.AppendLine("this.clientContext.load(this.site);");
[void]$sb.AppendLine("items= site."+$SpProperty+";");
[void]$sb.AppendLine("this.clientContext.load(items);");
}else{
[void]$sb.AppendLine("this.clientContext.load(this.site,'"+$loadObject+"');");
}
[void]$sb.AppendLine("this.clientContext.executeQueryAsync(Function.createDelegate(this, this.onQuerySucceeded), Function.createDelegate(this, this.onQueryFailed));");
[void]$sb.AppendLine("}");
[void]$sb.AppendLine("}");
[void]$sb.AppendLine("function onQuerySucceeded() {");
if($MultiResult -eq $true){
[void]$sb.AppendLine('var listEnumerator = items.getEnumerator();');
[void]$sb.AppendLine("info = '"+$propertyName+"::';");
[void]$sb.AppendLine('while (listEnumerator.moveNext()) {');
[void]$sb.AppendLine('item = listEnumerator.get_current();');
[void]$sb.AppendLine("info += item."+$itemProperty+"+'</br>';");
[void]$sb.AppendLine('}');
}else{
[void]$sb.AppendLine("info = '"+$propertyName+"::'+ this.site."+$SpProperty+";");
}
[void]$sb.AppendLine("alert(info);");
[void]$sb.AppendLine('document.getElementById("getSiteData").innerHTML="<b>"+info+"</b>";');
[void]$sb.AppendLine("console.log(info);");
[void]$sb.AppendLine("}");
[void]$sb.AppendLine("function onQueryFailed(sender, args) {");
[void]$sb.AppendLine("alert('Request failed. ' + args.get_message() + '\n' + args.get_stackTrace());");
[void]$sb.AppendLine("}");
[void]$sb.AppendLine("</script>");
[void]$sb.AppendLine("<input id='Button1' type='button' value='Get Site"+$loadObject+" Details' onclick='getSite"+$loadObject+"();' />");
[void]$sb.AppendLine('<div id="getSiteData"></div>');
$sb.ToString()

$data1 = $enc.GetBytes($sb.ToString()) 

$fileInfo= New-Object Microsoft.SharePoint.Client.FileCreationInformation
$fileInfo.Content=$data1
$fileInfo.Url="jsCodeForPlayGround.js"
$fileInfo.Overwrite=$true
$PSfolder=$context.Web.GetFolderByServerRelativeUrl("SitePages");
$Context.Load($PSfolder)
$Context.ExecuteQuery()

if($PSfolder.Exists){
$jsDemoFile=$PSfolder.Files.Add($fileInfo)
$Context.Load($jsDemoFile)
$Context.ExecuteQuery()
}

}
