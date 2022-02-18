function Get-PlexCollection
{
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true, ParameterSetName = "LibraryId")]
		[PSObject]
		$LibraryId,

		[Parameter(Mandatory = $true, ParameterSetName = "CollectionId")]
		[PSObject]
		$Id,

		[Parameter(Mandatory = $false)]
		[Switch]
		$IncludeItems
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
	if($Id)
	{
		$RestEndpoint = "library/collections/$($Id)?X-Plex-Token=$($DefaultPlexServer.Token)"

	}

	if($LibraryId)
	{
		$RestEndpoint = "library/sections/$($LibraryId)/collections?includeCollections=1&includeExternalMedia=1&includeAdvanced=1&includeMeta=1&X-Plex-Token=$($DefaultPlexServer.Token)"
	}


	#############################################################################
	try
	{
		$Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/$RestEndpoint" -Method GET
		if($Data.MediaContainer.metadata.count -eq 0)
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
		if($Id)
		{
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Appending collection item(s) for collection $($Data.MediaContainer.metadata.Title)"
			try
			{
				$RestEndpoint = "library/collections/$($Id)/children?excludeAllLeaves=1&X-Plex-Token=$($DefaultPlexServer.Token)"
				$Items = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/$RestEndpoint" -Method GET
				$Data.MediaContainer.metadata | Add-Member -NotePropertyName 'Items' -NotePropertyValue $Items.MediaContainer.metadata
			}
			catch
			{
				throw $_
			}
		}
		else
		{
			foreach($Collection in $Data.MediaContainer.Metadata)
			{
				Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Appending collection item(s) for collection $($Collection.title)"
				try
				{
					$RestEndpoint = "library/collections/$($Collection.RatingKey)/children?excludeAllLeaves=1&X-Plex-Token=$($DefaultPlexServer.Token)"
					$Items = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/$RestEndpoint" -Method GET
					$Collection | Add-Member -NotePropertyName 'Items' -NotePropertyValue $Items.MediaContainer.Metadata
				}
				catch
				{
					throw $_
				}
			}
		}
	}

	return $Data.MediaContainer.Metadata
}