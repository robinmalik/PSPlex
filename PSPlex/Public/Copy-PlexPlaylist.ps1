function Copy-PlexPlaylist
{
	<#
		.SYNOPSIS
		This function will copy a playlist from your account to another user account on your server.

		.DESCRIPTION
		This function will copy a playlist from your account to another user account on your server.
		Alternatively, if you wish to overwrite the destination playlist, use the -Force switch.

		.PARAMETER PlexServer
		The name of your Plex Server as you name it, within Plex Media Server (not the hostname of the machine it's running on).

		.PARAMETER PlaylistName
		Parameter description

		.PARAMETER NewPlayListName
		Create the playlist with a different name.

		.PARAMETER User
		The user you wish to copy the playlist to. Note: This can sometimes be a username, but at other times it will be an
		email address.

		.PARAMETER Force
		Overwrite the contents of the destination playlist.

		.EXAMPLE
		Copy-PlexPlaylist -PlaylistName 'MARVEL' -User 'user@domain.com'
	#>


	param(
		[Parameter(Mandatory = $true)]
		[String]
		$PlaylistName,

		[Parameter(Mandatory = $false)]
		[String]
		$NewPlaylistName,

		[Parameter(Mandatory = $true)]
		[String]
		$Username,

		[Parameter(Mandatory = $false)]
		[Switch]
		$Force
	)

	#############################################################################
	#Region Import Plex Configuration
	try
	{
		Import-PlexConfiguration
		$DefaultPlexServer = $PlexConfigData | Where-Object { $_.Default -eq $True }
	}
	catch
	{
		throw $_
	}
	#EndRegion


	#############################################################################
	# Get the machine ID property for the current plex server we're working with:
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting list of Plex servers"
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


	#############################################################################
	# Use the machine ID to get the server access tokens for the user we're targetting:
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting server access token for user $Username"
	try
	{
		$UserServerToken = Get-PlexUserToken -machineIdentifier $CurrentPlexServer.machineIdentifier -Username $Username
		if(!$UserServerToken)
		{
			throw "Could not find an access token for user $Username on server $($DefaultPlexServer.PlexServer). Check the username/email and whether they have access."
		}
	}
	catch
	{
		throw $_
	}


	#############################################################################
	# Get the Playlist we want to copy:
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting playlist $PlaylistName, including playlist items"
	try
	{
		# Get and filter:
		$Playlist = Get-PlexPlaylist -ErrorAction Stop | Where-Object { $_.title -eq $PlaylistName }
		if(!$Playlist)
		{
			throw "Could not find playlist $PlaylistName."
		}
		else
		{
			# We got a playlist. Now make another lookup by playlist ID and get the items in it:
			$Playlist = Get-PlexPlaylist -ID $Playlist.ratingKey -IncludeItems -ErrorAction Stop
		}
	}
	catch
	{
		throw $_
	}


	#############################################################################
	if($NewPlaylistName)
	{
		$PlaylistTitle = $NewPlaylistName
	}
	else
	{
		$PlaylistTitle = $Playlist.title
	}


	#############################################################################
	# Check whether the user already has a playlist by this name:
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Checking $Username account for existing playlist"
	try
	{
		[array]$Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists`?`X-Plex-Token=$($UserServerToken.Token)"

		$ExistingPlaylistsWithSameName = $Data.MediaContainer.Playlist | Where-Object { $_.title -eq $PlaylistTitle }
		if($ExistingPlaylistsWithSameName)
		{
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Removing existing playlist."
			foreach($PL in $ExistingPlaylistsWithSameName)
			{
				try
				{
					Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists/$($PL.ratingKey)`?`X-Plex-Token=$($UserServerToken.Token)" -Method DELETE | Out-Null
				}
				catch
				{
					Write-Warning -Message "Could not delete existing playlist."
					throw $_
				}
			}
		}
	}
	catch
	{
		throw $_
	}


	#############################################################################
	# Establish whether the playlist is smart or not; this will determine how we create it:
	# If playlist is not smart:
	if($Playlist.smart -eq 0)
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Original playlist is NOT smart."

		# Create a new playlist on the server, under the user's account:
		try
		{
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Creating playlist"
			$ItemsToAdd = $Playlist.Items.Metadata.ratingKey -join ','
			$Data = Invoke-RestMethod -Uri "http://$($CurrentPlexServer.address)`:$($CurrentPlexServer.port)/playlists?uri=server://$($CurrentPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$ItemsToAdd&title=$PlaylistTitle&smart=0&type=video&X-Plex-Token=$($UserServerToken.Token)" -Method "POST"
			return $Data.MediaContainer.Playlist
		}
		catch
		{
			throw $_
		}
	}
	elseif($Playlist.smart -eq 1)
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Original playlist is smart."

		# Although we have the playlist object from Get-PlexPlaylist, this function makes a query for all playlists before returning based on a match
		# by the playlist name. With this, we're not given a property called .content which contains the data that defines *how* the playlist is smart.

		# So, make an additional lookup to get the playlist explicitly by ID, and include the items this time:
		$PlaylistData = Get-PlexPlaylist -ID $Playlist.ratingKey -IncludeItems -ErrorAction Stop | Where-Object { $_.title -eq $PlaylistName }

		# Parse the data in the playlist to establish what parameters were used to create the smart playlist.
		# Split on the 'all?':
		$SmartPlaylistParams = ($PlaylistData.content -split 'all%3F')[1]
		try
		{
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Creating playlist"
			$Data = Invoke-RestMethod -Uri "http://$($CurrentPlexServer.address)`:$($CurrentPlexServer.port)/playlists?uri=server://$($CurrentPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/sections/2/all?$SmartPlaylistParams&title=$PlaylistTitle&smart=1&type=video&X-Plex-Product=Plex%20Web&X-Plex-Version=3.95.2&X-Plex-Client-Identifier=ni91ijrs5miuwc37d5esdrr3&X-Plex-Platform=Chrome&X-Plex-Platform-Version=75.0&X-Plex-Sync-Version=2&X-Plex-Model=bundled&X-Plex-Device=Windows&X-Plex-Device-Name=Chrome&X-Plex-Device-Screen-Resolution=1088x937%2C1920x1080&X-Plex-Token=$($UserServerToken.Token)&X-Plex-Language=en&X-Plex-Text-Format=plain" -Method "POST"
			return $Data.MediaContainer.Playlist
		}
		catch
		{
			throw $_
		}

	}
	else
	{
		Write-Warning -Message "Function: $($MyInvocation.MyCommand): No work done."
	}
}