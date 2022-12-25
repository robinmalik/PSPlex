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

	[CmdletBinding(SupportsShouldProcess)]
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
		$DataUri = Get-PlexAPIUri -RestEndpoint "status/sessions"
		$Data = Invoke-RestMethod -Uri $DataUri -Method GET -ErrorAction Stop
		if($Data.gettype().Name -eq 'String')
		{
			# Let's go with renaming the lowercase keys. Using .Replace rather than -replace as it should be faster.
			$Data = $Data.toString().Replace('"guid"', '"_guid"').Replace('"rating"', '"_rating"')
			# Convert back into JSON:
			$Data = $Data | ConvertFrom-Json
		}
		else
		{
			# $Data should be JSON already.
		}

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