function Get-PlexItem
{
	<#
		.SYNOPSIS

		.DESCRIPTION

		.EXAMPLE
			# Get a single item by ID:
			Get-PlexItem -ItemID 204
		.EXAMPLE
			# Get all items from the library called 'Films'.
			# NOTE: Not all data for an item is returned this way.
			$Items = Get-PlexItem -All -LibraryTitle Films

			# Get all data for the above items:
			$AllData = $Items | % { Get-PlexItem -ItemID $_.ratingKey }

			# Show movies using old Plex agent and update the metadata:
			$ToRefresh = $AllData | Where-Object { $_.guid[0] -notmatch "plex://movie"}
			foreach($Item in $ToRefresh)
			{
				Update-PlexItemMetadata -ItemID $Item.ratingKey
			}
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true, ParameterSetName = 'ItemID')]
		[String]
		$Id,

		[Parameter(Mandatory = $true, ParameterSetName = 'All')]
		[Switch]
		$All,

		[Parameter(Mandatory = $true, ParameterSetName = 'All')]
		[String]
		$LibraryTitle
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
		Write-Verbose -Message "Get item by ID"
		$RestEndpoint = "library/metadata/$Id"
	}
	elseif($All)
	{
		Write-Verbose -Message "Get items in library"
		$Library = Get-PlexLibrary | Where-Object { $_.title -eq $LibraryTitle }
		if(!$Library)
		{
			throw "No such library. Run Get-PlexLibrary to see a list."
		}
		else
		{
			$RestEndPoint = "library/sections/$($Library.key)/all"
			$Params = [Ordered]@{
				type                 = 1
				sort                 = 'titleSort'
				includeCollections   = 1
				includeExternalMedia = 1
				includeGuids         = 1
			}
			[String]$ExtraParamString = (($Params.GetEnumerator() | ForEach-Object { $_.Name + '=' + $_.Value }) -join '&') + "&"
		}
	}
	else
	{

	}

	try
	{
		$Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/$RestEndpoint`?$($ExtraParamString)X-Plex-Token=$($DefaultPlexServer.Token)" -Method GET

		# Deal with duplicate key error:
		$Items = ($Data.toString().Replace('guid', '_guid') | ConvertFrom-Json).Mediacontainer.Metadata

		return $Items
	}
	catch
	{
		throw $_
	}

}