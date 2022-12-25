function Add-PlexLabel
{
	<#
		.SYNOPSIS
			Adds a label to a Plex item (movie, show, or album).
		.DESCRIPTION
			Labels attached on movies, shows or albums are useful when sharing
			library content with others; you can choose to only show items with
			specific labels, or to hide items with specific labels.
		.PARAMETER Id
			Id of the item to add the label to.
		.PARAMETER Label
			The label to add.
		.EXAMPLE
			Add-PlexLabel -Id 12345 -Label 'FLAC'
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
		$Item = Get-PlexItem -Id $Id
	}
	catch
	{
		throw $_
	}
	#EndRegion


	#############################################################################
	#Region Simple checks:
	# If the item already has this label:
	if($Item.Label.Tag -contains $Label)
	{
		Write-Verbose -Message "Item already has label '$Label'"
		return
	}
	#EndRegion

	#############################################################################
	# Note: this includes a forwards slash at the start, so Invoke-RestMethod caters to that.
	$RestEndpoint = "$($Item.librarySectionKey)/all"


	#############################################################################
	# Combine existing labels (if there are any, force casting to an array) along
	# with the user specified label, and construct a parameter string:
	$Index = 0
	foreach($String in ([Array]$Item.Label.Tag + $Label))
	{
		$LabelString += "&label[$($Index)].tag.tag=$($String)"
		$Index++
	}

	#############################################################################
	# Get the type id/value for this item:
	$Type = Get-PlexItemTypeId -Type $Item.Type


	#############################################################################
	#Region Construct $ExtraParamString:
	$Params = [Ordered]@{
		id                   = $Item.ratingKey
		type                 = $Type
		includeExternalMedia = 1
	}

	[String]$ExtraParamString = (($Params.GetEnumerator() | ForEach-Object { $_.Name + '=' + $_.Value }) -join '&') + $LabelString + "&"
	#EndRegion


	#############################################################################
	# Region Make request to add label:
	Write-Verbose -Message "Adding label '$Label' to item '$($Item.title)'"
	try
	{
		Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)$($RestEndpoint)`?$($ExtraParamString)X-Plex-Token=$($DefaultPlexServer.Token)" -Method PUT
	}
	catch
	{
		throw $_
	}
	#EndRegion
}