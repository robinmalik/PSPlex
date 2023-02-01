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
		$Params
	)

	# If the endpoint starts with /, strip it off:
	if($RestEndpoint.StartsWith('/'))
	{
		$RestEndpoint = $RestEndpoint.Substring(1)
	}

	# Join the parameters as key=value pairs, and concatenate them with &
	if($Params)
	{
		# If the calling function hasn't passed a token as part of $Params, then add the default token to function as the default user:
		if($Null -eq $Params["X-Plex-Token"])
		{
			$Params.Add("X-Plex-Token", $DefaultPlexServer.Token)
		}

		[String]$ExtraParamString = (($Params.GetEnumerator() | ForEach-Object { $_.Name + '=' + $_.Value }) -join '&') + "&"
	}
	else
	{
		[String]$ExtraParamString = "X-Plex-Token=$($DefaultPlexServer.Token)"
	}

	return "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/$RestEndpoint`?$($ExtraParamString)"
}