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

	[CmdletBinding()]
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
			Import-PlexConfiguration
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

		$Params = [Ordered]@{
			sort = "viewedAt:desc"
		}

		# If we have a username, add it to the query
		if($UsernameId)
		{
			$Params.Add("accountID", $UsernameId)
		}

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
		# Plex caps the number of items returned per request, so page through the results using
		# X-Plex-Container-Start / X-Plex-Container-Size until we have collected everything.
		$ContainerStart = 0
		$ContainerSize = 1000
		$Results = [System.Collections.Generic.List[object]]::new()

		do
		{
			$PageParams = [Ordered]@{}
			foreach($Key in $Params.Keys) { $PageParams[$Key] = $Params[$Key] }
			$PageParams['X-Plex-Container-Start'] = $ContainerStart
			$PageParams['X-Plex-Container-Size'] = $ContainerSize

			$Data = Invoke-PlexRequest -RestEndpoint $RestEndpoint -Params $PageParams -Method GET

			$TotalSize = [Int]$Data.MediaContainer.totalSize
			[array]$Page = $Data.MediaContainer.Metadata
			if($Page)
			{
				$Results.AddRange($Page)
			}

			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Retrieved $($Results.Count) of $TotalSize items."
			# Advance by the number actually returned, in case Plex returns fewer than requested.
			$ContainerStart += $Page.Count
		}
		while($Results.Count -lt $TotalSize -and $Page.Count -gt 0)

		# Append a human readable "viewedAt" property to the object.
		$Results | ForEach-Object {
			if($Null -ne $_.viewedAt) { $_ | Add-Member -NotePropertyName 'lastViewedAtDateTime' -NotePropertyValue (ConvertFrom-UnixTime $_.viewedAt) -Force }
		}

		#############################################################################
		# Append type for readability
		$Results | ForEach-Object { $_.psobject.TypeNames.Insert(0, "PSPlex.WatchHistory") }

		# Return results:
		$Results
	}
	catch
	{
		throw $_
	}
	#EndRegion
}