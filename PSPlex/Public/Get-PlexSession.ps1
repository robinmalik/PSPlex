function Get-PlexSession
{
	[CmdletBinding(SupportsShouldProcess)]
	param(
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

	$RestEndpoint = "status/sessions"

	#############################################################################
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting all sessions"
	try
	{
		$Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/$RestEndpoint`?`X-Plex-Token=$($DefaultPlexServer.Token)" -Method GET -ErrorAction Stop
		if($Data.MediaContainer.Size -eq 0)
		{
			return
		}

		$Results = $Data.MediaContainer.Metadata
	}
	catch
	{
		throw $_
	}

	#############################################################################
	# Append type and return results
	$Results | ForEach-Object { $_.psobject.TypeNames.Insert(0, "PSPlex.Session") }
	return $Results
}