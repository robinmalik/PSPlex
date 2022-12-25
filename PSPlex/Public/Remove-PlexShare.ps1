function Remove-PlexShare
{
	<#
		.SYNOPSIS
			Removes a shared library from a user.
		.DESCRIPTION
			Removes a shared library from a user.
		.PARAMETER Username
			The username to remove the shared library from.
		.PARAMETER LibraryTitle
			The name of the library to unshare.
		.PARAMETER LibraryId
			The id of the library to unshare.
		.EXAMPLE
			Remove-PlexShare -Username 'myfriend' -LibraryTitle 'Films'
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$Username,

		[Parameter(Mandatory = $true, ParameterSetName = 'LibraryTitle')]
		[String]
		$LibraryTitle,

		[Parameter(Mandatory = $true, ParameterSetName = 'LibraryId')]
		[Int]
		$LibraryId
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
	#Region Get User
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting user."
	try
	{
		$User = Get-PlexUser -User $Username -ErrorAction Stop
		if(($Null -eq $User) -or ($User.count -eq 0))
		{
			throw "Could not get the user '$Username'"
		}

		# When viewing the libraries shared to a user via the web client, it makes a request to
		# https://plex.tv/api/v2/shared_servers/$someid where $someid appears to be a unique Id
		# assigned to the user for the server in question. It's not the normal Plex user id.
		# Extract it from the Server property on the user object, making sure we match against the right
		# server of course.
		$UserIdOnServer = ($User.server | Where-Object { $_.name -eq $DefaultPlexServer.PlexServer }).Id
		if(!$UserIdOnServer)
		{
			throw "Could not determine user id on server: $($DefaultPlexServer.PlexServer). Are you sure the user '$Username' has access to any libraries?"
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#############################################################################
	#Region Confirm library access
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Checking User Access to Library"
	try
	{
		$DataForUser = Invoke-RestMethod -Uri "https://plex.tv/api/v2/shared_servers/$UserIdOnServer`?X-Plex-Token=$($DefaultPlexServer.Token)&X-Plex-Client-Identifier=PowerShell" -Method GET -ErrorAction Stop
		if(($Null -eq $DataForUser.libraries) -or ($DataForUser.libraries.count -eq 0))
		{
			throw "No shared libraries with user: $Username"
		}

		if($LibraryTitle)
		{
			if($Null -eq ($DataForUser.libraries | Where-Object { $_.title -eq $LibraryTitle }))
			{
				throw "The library '$LibraryTitle' is not shared with user: $Username"
			}

			if(($DataForUser.libraries | Where-Object { $_.title -eq $LibraryTitle }).Count -gt 1)
			{
				throw "Multiple libraries found called '$LibraryTitle'. Re-run this function using -LibraryId instead of -LibraryTitle to target a specific library."
			}

			# Grab the Id for the library:
			$LibraryId = ($DataForUser.libraries | Where-Object { $_.title -eq $LibraryTitle }).Id
		}
		elseif($LibraryId)
		{
			if($Null -eq ($DataForUser.libraries | Where-Object { $_.Id -eq $LibraryId }))
			{
				throw "The library with Id '$LibraryId' is not shared with user: $Username"
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
	# At this point we know the user has access to the library. Remove:
	try
	{
		# If the result of this leaves the user with 0 libraries, we need to make a DELETE request.
		# If the result of this leaves the user with 1 or more libraries, we need to make a POST request.
		# So, if there's just 1 we need to delete everything, else post...
		if($DataForUser.libraries.count -eq 1)
		{
			$Method = 'DELETE'
			Write-Verbose -Message "Removing library with $($Method)"
			Invoke-RestMethod -Uri "https://plex.tv/api/v2/shared_servers/$UserIdOnServer`?X-Plex-Token=$($DefaultPlexServer.Token)&X-Plex-Client-Identifier=PowerShell" -Method $Method -ErrorAction Stop | Out-Null
			return
		}
		else
		{
			$Method = 'POST'

			# The body for this post needs to be a list of all library IDs excluding the one we're removing.
			$LibraryIdsToKeep = $DataForUser.libraries | Where-Object { $_.Id -ne $LibraryId } | Select-Object -Expand id

			# We have to construct the body object slightly differently depending on whether we're passing an array of library
			# IDs or just 1 Id, so that when converted to JSON it's the right format for Plex:
			if($LibraryIdsToKeep.Count -gt 1)
			{
				$Body = @{
					machineIdentifier = "$($MatchingServer.machineIdentifier)"
					librarySectionIds = $LibraryIdsToKeep
				} | ConvertTo-Json -Compress
			}
			else
			{
				$Body = @{
					machineIdentifier = "$($MatchingServer.machineIdentifier)"
					librarySectionIds = @($LibraryIdsToKeep)
				} | ConvertTo-Json -Compress
			}
			Write-Verbose -Message "Removing library with $($Method): $LibraryTitle"
			Invoke-RestMethod -Uri "https://plex.tv/api/v2/shared_servers/$UserIdOnServer`?X-Plex-Token=$($DefaultPlexServer.Token)&X-Plex-Client-Identifier=PowerShell" -Method $Method -ContentType "application/json" -Body $Body -ErrorAction Stop | Out-Null
		}
	}
	catch
	{
		throw $_
	}
}