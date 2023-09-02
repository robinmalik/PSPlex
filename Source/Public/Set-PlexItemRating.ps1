function Set-PlexItemRating
{
	<#
		.SYNOPSIS
			Sets the rating on a Plex item.
		.DESCRIPTION
			Sets the rating on a Plex item. Must be between 1-5.
		.PARAMETER Id
			The id of the item.
		.PARAMETER Rating
			Rating value.
		.EXAMPLE
			Set-PlexItemRating -Id 12345 -Rating 3
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$Id,

		[Parameter(Mandatory = $true)]
		[ValidateRange(1, 5)]
		[Int]
		$Rating
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
	#Region Submit rating
	if($PSCmdlet.ShouldProcess($Id, "Set rating to $Rating"))
	{
		Write-Verbose -Message "Submitting rating"
		try
		{
			$RestEndpoint = ":/rate"
			$Params = [Ordered]@{
				key        = $Id
				rating     = $($Rating * 2)
				identifier = 'com.plexapp.plugins.library'
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
