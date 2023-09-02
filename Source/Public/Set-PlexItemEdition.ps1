function Set-PlexItemEdition
{
	<#
		.SYNOPSIS
			Sets the edition on a Plex (movie) item.
		.DESCRIPTION
			Sets the edition on a Plex (movie) item.
		.PARAMETER Id
			The id of the item.
		.PARAMETER Edition
			Edition value.
		.EXAMPLE
			Set-PlexItemRating -Id 12345 -Edition "Director's Cut"
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$Id,

		[Parameter(Mandatory = $true)]
		[String]
		$Edition
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
	#Region Get the Item
	try
	{
		$Item = Get-PlexItem -Id $Id -ErrorAction Stop
		if($Item.type -ne 'movie')
		{
			throw "Plex only supports setting the edition on movies. Item type is: $($Item.type)"
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#############################################################################
	#Region Submit rating
	if($PSCmdlet.ShouldProcess($Id, "Set edition to $Edition"))
	{
		Write-Verbose -Message "Setting edition"
		try
		{
			$RestEndpoint = "$($Item.librarySectionKey)/all"
			$Params = [Ordered]@{
				type                 = 1
				id                   = $Id
				"editionTitle.value" = $Edition
			}
			$Uri = Get-PlexAPIUri -RestEndpoint $RestEndpoint -Params $Params
			Invoke-RestMethod -Uri $Uri -Method Put
		}
		catch
		{
			throw $_
		}
	}
	#EndRegion
}