function Get-PlexPlaylist
{
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $false)]
		[String]
		$Id,

		[Parameter(Mandatory = $false)]
		[Switch]
		$IncludeItems,

		[Parameter(Mandatory = $false)]
		[String]
		$AlternativeToken
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

	$RestEndpoint = "playlists/$Id"

	#############################################################################
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting playlist(s)"
	try
	{
		if($AlternativeToken)
		{
			$Token = $AlternativeToken
		}
		else
		{
			$Token = $DefaultPlexServer.Token
		}


		# Plex decided to automatically create Playlists with heart emojis in for music playlists.
		# When calling Invoke-RestMethod, PowerShell ends up converting these to squiggly a characters.
		# To work around this, we have to use Invoke-WebRequest and take the RawContentStream property
		# and use that.
		$Data = Invoke-WebRequest -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/$RestEndpoint`?`X-Plex-Token=$($Token)" -ErrorAction Stop
		if($Data)
		{
			$UTF8String = [system.Text.Encoding]::UTF8.GetString($Data.RawContentStream.ToArray())
			[array]$Results = ($UTF8String | ConvertFrom-Json).MediaContainer.Metadata
		}
		else
		{
			return
		}
	}
	catch
	{
		throw $_
	}


	#############################################################################
	if($IncludeItems)
	{
		foreach($Playlist in $Results)
		{
			$RestEndpoint = "playlists/$($Playlist.ratingKey)/items"
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Appending playlist item(s)"
			try
			{
				[array]$Items = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/$RestEndpoint`?`X-Plex-Token=$($DefaultPlexServer.Token)" -ErrorAction Stop
				$Playlist | Add-Member -NotePropertyName 'Items' -NotePropertyValue $Items.MediaContainer
			}
			catch
			{
				throw $_
			}
		}
	}

	#############################################################################
	# Append type and return results
	$Results | ForEach-Object { $_.psobject.TypeNames.Insert(0, "PSPlex.Playlist") }
	return $Results
}