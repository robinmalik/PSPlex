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
		.PARAMETER ItemId
			Id (ratingKey) of the Plex items to add. Can be a single item, comma separated list, or an array.
		.EXAMPLE
			New-PlexPlaylist -Name "My Playlist" -Type video -ItemId 123,456,789
		.EXAMPLE
			$Item = Find-PlexItem -ItemName "Some Movie"
			New-PlexPlaylist -Name "My Playlist" -Type video -ItemId $Item.ratingKey
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
			Import-PlexConfiguration
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
	#Region Construct Uri
	try
	{
		$Items = $ItemId -join ","
		$Params = [Ordered]@{
			title = $Name
			type  = $Type
			smart = 0
			uri   = "server://$($DefaultPlexServer.ClientIdentifier)/com.plexapp.plugins.library/library/metadata/$Items"
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#############################################################################
	#Region Make request
	if($PSCmdlet.ShouldProcess($Name, "Create playlist"))
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Creating playlist '$Name'"
		try
		{
			$Data = Invoke-PlexRequest -RestEndpoint "playlists" -Params $Params -Method POST
			return $Data.mediacontainer.metadata
		}
		catch
		{
			throw $_
		}
	}
	#EndRegion
}