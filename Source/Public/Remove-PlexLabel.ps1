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
			Import-PlexConfiguration -WhatIf:$False
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
	# If the item has no labels:
	if(!$Item.Label.Tag)
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Item has no labels"
		return
	}

	# If the item doesn't have this label:
	if($Item.Label.Tag -notcontains $Label)
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Item does not have the label '$Label'"
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
		$Params = [Ordered]@{
			id                   = $Item.ratingKey
			type                 = $Type
			includeExternalMedia = 1
		}

		# Keep the existing labels (if there are any, force casting to an array) except
		# for the user specified label:
		$Index = 0
		foreach($String in ([Array]$Item.Label.Tag | Where-Object { $_ -ne $Label }))
		{
			$Params.Add("label[$($Index)].tag.tag", $String)
			$Index++
		}
		# Finally, to remove the label we need to add it like so:
		$Params.Add('label[].tag.tag-', $Label)

		$DataUri = Get-PlexAPIUri -RestEndpoint "$($Item.librarySectionKey)/all" -Params $Params
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#############################################################################
	#Region Make request
	if($PSCmdlet.ShouldProcess($Item.title, "Remove label '$Label'"))
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Removing label '$Label' from item '$($Item.title)'"
		try
		{
			Invoke-RestMethod -Uri $DataUri -Method PUT
		}
		catch
		{
			throw $_
		}
	}
	#EndRegion
}