function New-PlexPlaylist
{
	<#
		.SYNOPSIS
			Creates a new playlist.
		.DESCRIPTION
			Creates a new playlist.
		.PARAMETER Name
			Name of the playlist.
		.PARAMETER Type
			Type of playlist. Currently only 'video' is supported.
		.PARAMETER Id
			Id (ratingKey) of the Plex items to add. Can be a single item, comma separated list, or an array.
		.EXAMPLE
			New-PlexPlaylist -Name "My Playlist" -Type video -Id 123,456,789
		.EXAMPLE
			$Item = Find-PlexItem -Name "Some Movie"
			New-PlexPlaylist -Name "My Playlist" -Type video -Id $Item.ratingKey
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$Name,

		[Parameter(Mandatory = $true)]
		[ValidateSet('video')]
		[String]
		$Type,

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
	#Region Check if playlist already exists
	try
	{
		$Playlists = Get-PlexPlaylist
		if($Playlists.title -contains $Name)
		{
			throw "Playlist '$Name' already exists"
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#############################################################################
	#Region Get machine identifier
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting list of Plex servers (to get machine identifier)"
	try
	{
		$CurrentPlexServer = Get-PlexServer -Name $DefaultPlexServer.PlexServer -ErrorAction Stop
		if(!$CurrentPlexServer)
		{
			throw "Could not find $CurrentPlexServer in $($Servers -join ', ')"
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#############################################################################
	#Region Construct Uri
	try
	{
		$Items = $ItemId -join ","
		$Params = [Ordered]@{
			title = $Name
			type  = $Type
			smart = 0
			uri   = "server://$($CurrentPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$Items"
		}
		$DataUri = Get-PlexAPIUri -RestEndpoint "playlists" -Params $Params
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
			$Data = Invoke-RestMethod -Uri $DataUri -Method POST
			return $Data.mediacontainer.metadata
		}
		catch
		{
			throw $_
		}
	}
	#EndRegion
}