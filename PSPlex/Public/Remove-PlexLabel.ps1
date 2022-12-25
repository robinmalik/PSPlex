function Remove-PlexLabel
{
	<#
		.SYNOPSIS
			Removes a label from a Plex item (movie, show, or album).
		.DESCRIPTION
			Labels attached on movies, shows or albums are useful when sharing
			library content with others; you can choose to only show items with
			specific labels, or to hide items with specific labels.
		.PARAMETER Id
			Id of the item to remove the label from.
		.PARAMETER Label
			The label to remove.
		.EXAMPLE
			Remove-PlexLabel -Id 12345 -Label 'FLAC'
		.NOTES
			Only movies, shows and albums support labels.
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$Id,

		[Parameter(Mandatory = $true)]
		[String]
		$Label
	)

	#############################################################################
	#Region Import Plex Configuration
	if(!$script:PlexConfigData)
	{
		try
		{
			Import-PlexConfiguration
		}
		catch
		{
			throw $_
		}
	}
	#EndRegion

	#############################################################################
	#Region Get the item
	try
	{
		$Item = Get-PlexItem -Id $Id -ErrorAction Stop
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#############################################################################
	#Region Simple checks:
	# If the item has no labels:
	if(!$Item.Label.Tag)
	{
		Write-Verbose -Message "Item has no labels"
		return
	}

	# If the item doesn't have this label:
	if($Item.Label.Tag -notcontains $Label)
	{
		Write-Verbose -Message "Item does not have the label '$Label'"
		return
	}
	#EndRegion

	#############################################################################
	# Get the type id/value for this item:
	$Type = Get-PlexItemTypeId -Type $Item.Type

	#############################################################################
	#Region Construct Uri
	try
	{
		# Keep the existing labels (if there are any, force casting to an array) except
		# for the user specified label, and construct a parameter string:
		$Index = 0
		foreach($String in ([Array]$Item.Label.Tag | Where-Object { $_ -ne $Label }))
		{
			$LabelString += "&label[$($Index)].tag.tag=$($String)"
			$Index++
		}
		# Finally, to remove the label we need to add it like so:
		$LabelString += "&label[].tag.tag-=$Label"

		$Params = [Ordered]@{
			id                   = $Item.ratingKey
			type                 = $Type
			includeExternalMedia = 1
		}

		$DataUri = Get-PlexAPIUri -RestEndpoint "$($Item.librarySectionKey)/all" -Params $Params
		$DataUri = $DataUri + $LabelString
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#############################################################################
	#Region Make request to remove label:
	Write-Verbose -Message "Removing label '$Label' from item '$($Item.title)'"
	try
	{
		Invoke-RestMethod -Uri $DataUri -Method PUT
	}
	catch
	{
		throw $_
	}
	#EndRegion
}