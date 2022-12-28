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
	# If the item already has this label:
	if($Item.Label.Tag -contains $Label)
	{
		Write-Verbose -Message "Item already has label '$Label'"
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
		# Combine existing labels (if there are any, force casting to an array)
		# and the user specified label. Append to params.
		# Format: &label[0].tag.tag=MyLabel&label[1].tag.tag=AnotherLabel
		$Index = 0
		foreach($String in ([Array]$Item.Label.Tag + $Label))
		{
			$Params.Add("label[$($Index)].tag.tag", $String)
			$Index++
		}
		$DataUri = Get-PlexAPIUri -RestEndpoint "$($Item.librarySectionKey)/all" -Params $Params
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#############################################################################
	#Region Make request
	if($PSCmdlet.ShouldProcess($Item.title, "Add label '$Label'"))
	{
		Write-Verbose -Message "Adding label '$Label' to item '$($Item.title)'"
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