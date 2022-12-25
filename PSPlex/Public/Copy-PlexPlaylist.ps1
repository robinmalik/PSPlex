function Copy-PlexPlaylist
{
	<#
		.SYNOPSIS
			This function will copy a playlist from your account to another user account on your server.
			Note: If the destination user already has a playlist with this name, a second one will be created.
			To overwrite, use the -Force switch.
		.DESCRIPTION
			This function will copy a playlist from your account to another user account on your server.
			Note: If the destination user already has a playlist with this name, a second one will be created.
			To overwrite, use the -Force switch.
		.PARAMETER Id
			Id of the playlist you wish to copy. To get this, use 'Get-PlexPlaylist'.
		.PARAMETER NewPlaylistName
			Create the playlist with a different name.
		.PARAMETER Username
			The username for the account you wish to copy the playlist to.
		.PARAMETER Force
			Overwrite the contents of an existing playlist.
		.EXAMPLE
			Copy-PlexPlaylist -Id 12345 -User 'user@domain.com'
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$Id,

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
	#Region Get the Playlist we want to copy
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting playlist $Id, including playlist items"
	try
	{
		# Get and filter:
		$Playlist = Get-PlexPlaylist -Id $Id -IncludeItems -ErrorAction Stop
		if(!$Playlist)
		{
			throw "Could not find playlist with id $Id."
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion


	#############################################################################
	#Region Get the target user along with user token for our server
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting user."
	try
	{
		$User = Get-PlexUser -User $Username -IncludeToken -ErrorAction Stop
		if(($Null -eq $User) -or ($User.count -eq 0))
		{
			throw "Could not get user: $Username"
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion


	#############################################################################
	#Region Create a new variable to store the destination playlist name
	if($NewPlaylistName)
	{
		$PlaylistTitle = $NewPlaylistName
	}
	else
	{
		$PlaylistTitle = $Playlist.title
	}
	#EndRegion

	#############################################################################
	#Region Check whether the user already has a playlist by this name.
	# It's worth noting that you can have multiple playlists with the same name (sigh).
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Checking $Username account for existing playlist"
	try
	{
		[Array]$ExistingPlaylistsWithSameName = Get-PlexPlaylist -AlternativeToken $User.token -ErrorAction Stop | Where-Object { $_.title -eq $PlaylistTitle }
		if($ExistingPlaylistsWithSameName.Count -gt 1)
		{
			# If there is more than 1 playlist with the same name in the destination account, we
			# 1) wouldn't know which we wanted to overwrite and
			# 2) wouldn't want to remove them automatically when -Force is used, so warn and exit.
			Write-Warning -Message "Multiple playlists with the name '$PlaylistTitle' exist under the destination account $Username. You can review these with 'Get-PlexPlaylist' and remove with 'Remove-PlexPlaylist' (after obtaining a user token for $Username with 'Get-PlexUser -Username $Username -IncludeToken')."
			return
		}
		elseif($ExistingPlaylistsWithSameName.Count -eq 1)
		{
			if($Force)
			{
				Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Playlist already exists in destination account. Removing."
				foreach($PL in $ExistingPlaylistsWithSameName)
				{
					try
					{
						#Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists/$($PL.ratingKey)`?`X-Plex-Token=$($User.Token)" -Method DELETE | Out-Null
						Remove-PlexPlaylist -Id $PL.ratingKey -AlternativeToken $User.Token -ErrorAction Stop | Out-Null
					}
					catch
					{
						Write-Warning -Message "Could not delete existing playlist."
						throw $_
					}
				}
			}
			else
			{
				Write-Warning -Message "The destination account already has a Playlist with the name '$PlaylistTitle'. To overwrite it, call this function with the -Force parameter."
				return
			}
		}
		else
		{
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion


	#############################################################################
	#Region Get the machine Id property for the current plex server we're working with:
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
	# Establish whether the playlist is smart or not; this will determine how we create it:
	# If playlist is not smart:
	if($Playlist.smart -eq 0)
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Original playlist is NOT smart."

		# Create a new playlist on the server, under the user's account:
		try
		{
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Creating playlist"
			$ItemsToAdd = $Playlist.Items.ratingKey -join ','
			$Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists?uri=server://$($CurrentPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$ItemsToAdd&title=$PlaylistTitle&smart=0&type=$($PlayList.playlistType)&X-Plex-Token=$($User.Token)" -Method POST
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

		# So, make an additional lookup to get the playlist explicitly by Id, and include the items this time:
		$PlaylistData = Get-PlexPlaylist -Id $Playlist.ratingKey -IncludeItems -ErrorAction Stop | Where-Object { $_.title -eq $PlaylistName }

		# Parse the data in the playlist to establish what parameters were used to create the smart playlist.
		# Split on the 'all?':
		$SmartPlaylistParams = ($PlaylistData.content -split 'all%3F')[1]
		try
		{
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Creating playlist"
			$Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/playlists?uri=server://$($CurrentPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/sections/2/all?$SmartPlaylistParams&title=$PlaylistTitle&smart=1&type=video&X-Plex-Product=Plex%20Web&X-Plex-Version=3.95.2&X-Plex-Client-Identifier=ni91ijrs5miuwc37d5esdrr3&X-Plex-Platform=Chrome&X-Plex-Platform-Version=75.0&X-Plex-Sync-Version=2&X-Plex-Model=bundled&X-Plex-Device=Windows&X-Plex-Device-Name=Chrome&X-Plex-Device-Screen-Resolution=1088x937%2C1920x1080&X-Plex-Token=$($User.Token)&X-Plex-Language=en&X-Plex-Text-Format=plain" -Method POST
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