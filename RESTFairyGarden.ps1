#Replace the URL with your URL for targetSite and your User for User
#Create a Garden Subsite
$data=@"
{'parameters':{'__metadata': { 'type': 'SP.WebInfoCreationInformation' },'Url': 'Garden','Title': 'Garden', 'Description': 'Garden web','Language': 1033,'WebTemplate': 'sts','UseUniquePermissions': false}}
"@
$restUrl="/_api/web/webinfos/add"
$targetSite="https://xxx.sharepoint.com/sites/dev"
$User="admin@xxx.onmicrosoft.com"
$siteNew=Create-SPObject -targetSite $targetSite -User $User -restUrl $restUrl -data $data

#Create a list named fruits
$data=@"
{ '__metadata': { 'type': 'SP.List' }, 'AllowContentTypes': true, 'BaseTemplate': 100,
    'ContentTypesEnabled': true, 'Description': 'My Fruits List', 'Title': 'Fruits' }
"@
$targetSite="https://xxx.sharepoint.com/sites/dev/Garden"
$User="admin@xxx.onmicrosoft.com"
$restUrl="/_api/web/lists"
$listNew=Create-SPObject -targetSite $targetSite -User $User -restUrl $restUrl -data $data

#Create a column Location
$data=@"
{ '__metadata': { 'type': 'SP.Field' }, 'Title': 'Location', 'FieldTypeKind': 2 }
"@
$listName="Fruits"
$restUrl="/_api/web/lists/getbytitle('$($listName)')/fields"
$listFieldNew=Create-SPObject -targetSite $targetSite -User $User -restUrl $restUrl -data $data

#Add five items
$items="Apple","Orange","Mango","Kiwi","Pomogranate"
$location="Washington"
$listName="Fruits"
$restUrl="/_api/web/lists/GetByTitle('"+$listName+"')/items"
foreach ($item in $items)
{
    $data=@"
{ '__metadata': { 'type': 'SP.Data.$($listName)ListItem' }, 'Title': '$($item)','Location':'$($location)' }
"@
$listItemNew=Create-SPObject -targetSite $targetSite -User $User -restUrl $restUrl -data $data
}


#Read List Items
$restUrl="/_api/web/lists/getbytitle('$($listName)')/items"
$listsFruits=Read-SPObject -targetSite $targetSite -User $User -restUrl $restUrl
$results = $listsFruits.ToString().Replace("ID", "_ID") | ConvertFrom-Json
$results.d.results|select Title,Location,Id

#Read the Apple item
$restUrl="/_api/web/lists/getbytitle('$($listName)')/items?`$filter=Title eq 'Apple'"
$listsFruits=Read-SPObject -targetSite $targetSite -User $User -restUrl $restUrl
$results = $listsFruits.ToString().Replace("ID", "_ID") | ConvertFrom-Json
$results.d.results|select Title,Location,Id
$etag=$results.d.results[0].__metadata.etag
$listItemID=$results.d.results[0].id

#Update the item
$UpdatedValue="Australia"
$restUrl="/_api/web/lists/GetByTitle('"+$listName+"')/items("+$listItemID+")"
$data="{'__metadata': { 'type': 'SP.Data.$($listName)ListItem' }, 'Location': '$($UpdatedValue)'}"
$updatedItem=Update-SPObject -targetSite $targetSite -User $User -restUrl $restUrl -data $data -etag $etag 

#Read the Mango item
$restUrl="/_api/web/lists/getbytitle('$($listName)')/items?`$filter=Title eq 'Mango'"
$listsFruits=Read-SPObject -targetSite $targetSite -User $User -restUrl $restUrl
$results = $listsFruits.ToString().Replace("ID", "_ID") | ConvertFrom-Json
$results.d.results|select Title,Location,Id
$etag=$results.d.results[0].__metadata.etag
$deletelistItemID=$results.d.results[0].id

#Delete the item
$restUrl="/_api/web/lists/GetByTitle('"+$listName+"')/items("+$deletelistItemID+")"
$listItemdeleted=Delete-SPObject -targetSite $targetSite -User $User -restUrl $restUrl