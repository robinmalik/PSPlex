function Get-PlexAPIUri
{
	<#
		.SYNOPSIS
			Returns a valid Uri for the Plex API.
		.DESCRIPTION
			Returns a valid Uri for the Plex API.
		.PARAMETER RestEndpoint
			The endpoint (the part after protocol://hostname:port/)
		.PARAMETER Params
			A hashtable/ordered hashtable of (URL) parameters
		.PARAMETER Token
			To make a request with another token (e.g. for a different user)
			use this parameter.
		.EXAMPLE
			$Params = @{
				sort = "titleSort"
			}
			$RestEndpoint = "library/sections/1/all"
			$DataUri = Get-PlexAPIUri -RestEndpoint $RestEndpoint -Params $Params
			Invoke-RestMethod -Uri $DataUri -Method GET
	#>

	[CmdletBinding()]
	[OutputType([System.String])]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$RestEndpoint,

		[Parameter(Mandatory = $false)]
		[System.Collections.IDictionary]
		$Params,

		[Parameter(Mandatory = $false)]
		[String]
		$Token
	)

	# If the endpoint starts with /, strip it off:
	if($RestEndpoint.StartsWith('/'))
	{
		$RestEndpoint = $RestEndpoint.Substring(1)
	}

	# Join the parameters as key=value pairs, and concatenate them with &
	if($Params)
	{
		[String]$ExtraParamString = (($Params.GetEnumerator() | ForEach-Object { $_.Name + '=' + $_.Value }) -join '&') + "&"
	}

	if(!$Token)
	{
		$Token = $DefaultPlexServer.Token
	}

	return "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/$RestEndpoint`?$($ExtraParamString)X-Plex-Token=$Token"
}