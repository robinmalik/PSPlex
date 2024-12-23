function Add-PlexItemToPlaylist
{
	<#
		.SYNOPSIS
			Copies a single item to a playlist.
		.DESCRIPTION
			Copies a single item to a playlist.
		.PARAMETER PlaylistId
			The id of the playlist.
		.PARAMETER ItemId
			Id (ratingKey) of the Plex items to add. Can be a single item, comma separated list, or an array.
		.EXAMPLE
			# Add an item to a playlist on the default plex server
			Add-PlexItemToPlaylist -PlaylistId 12345 -ItemId 7204
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$PlaylistId,

		[Parameter(Mandatory = $true)]
		[String[]]
		$ItemId
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
	#Region Construct Uri
	try
	{
		$Items = $ItemId -join ","
		$Params = [Ordered]@{
			uri = "server://$($DefaultPlexServer.ClientIdentifier)/com.plexapp.plugins.library/library/metadata/$Items"
		}
		$DataUri = Get-PlexAPIUri -RestEndpoint "playlists/$PlaylistID/items" -Params $Params
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#############################################################################
	#Region Make request
	if($PSCmdlet.ShouldProcess($PlaylistId, "Add item $ItemId to playlist"))
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Adding item to playlist."
		try
		{
			Invoke-RestMethod -Uri $DataUri -Method PUT | Out-Null
		}
		catch
		{
			throw $_
		}
	}

	#EndRegion
}