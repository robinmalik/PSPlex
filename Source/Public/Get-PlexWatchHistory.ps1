function Get-PlexWatchHistory
{
	<#
		.SYNOPSIS
			Returns a list of watched/listened to items from the Plex server.
		.DESCRIPTION
			Returns a list of watched/listened to items from the Plex server.
		.PARAMETER Username
			Optional. If specified, only return items watched by this user.
		.EXAMPLE
			Get-PlexWatchHistory
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $false)]
		[String]
		$Username
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
	#Region Get Username ID
	if($Username)
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting user ID for $Username."
		try
		{
			$UsernameId = Get-PlexUser -Username $Username | Select-Object -ExpandProperty Id
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
		$RestEndpoint = "status/sessions/history/all"

		$Offset = 0
		$size = 100
		$TotalSize = 0

		$Params = [Ordered]@{
			sort      = "viewedAt:desc"
			Offset    = $Offset
			size      = $size
			totalSize = $TotalSize
		}

		# If we have a username, add it to the query
		if($UsernameId)
		{
			$Params.Add("accountID", $UsernameId)
		}

		$DataUri = Get-PlexAPIUri -RestEndpoint $RestEndpoint -Params $Params
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#############################################################################
	#Region Get data
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting watch history for $Username."
	try
	{
		$Data = Invoke-RestMethod -Uri $DataUri -Method GET
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): $($Data.MediaContainer.size) items found."
		# The query seems to return all results so we don't need to page through them.

		# Append a human readable "viewedAt" property to the object.
		$Data.MediaContainer.Metadata | ForEach-Object {
			if($Null -ne $_.viewedAt) { $_ | Add-Member -NotePropertyName 'lastViewedAtDateTime' -NotePropertyValue (ConvertFrom-UnixTime $_.viewedAt) -Force }
		}

		#############################################################################
		# Append type for readability
		$Data.MediaContainer.Metadata | ForEach-Object { $_.psobject.TypeNames.Insert(0, "PSPlex.WatchHistory") }

		# Return results:
		$Data.MediaContainer.Metadata
	}
	catch
	{
		throw $_
	}
	#EndRegion
}