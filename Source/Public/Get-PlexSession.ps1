function Get-PlexSession
{
	<#
		.SYNOPSIS
			Gets a list of sessions (streams) on the Plex server.
		.DESCRIPTION
			Gets a list of sessions (streams) on the Plex server.
		.EXAMPLE
			Get-PlexSession
	#>

	[CmdletBinding()]
	param(
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
	#Region Get data
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting all sessions"
	try
	{
		$Data = Invoke-PlexRequest -RestEndpoint "status/sessions" -Method GET
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
	#EndRegion

	#############################################################################
	# Append type and return results
	$Results | ForEach-Object { $_.psobject.TypeNames.Insert(0, "PSPlex.Session") }
	return $Results
}