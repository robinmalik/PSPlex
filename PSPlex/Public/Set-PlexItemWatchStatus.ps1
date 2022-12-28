function Set-PlexItemWatchStatus
{
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$Id,

		[Parameter(Mandatory = $true)]
		[ValidateSet('played', 'unplayed')]
		[String]
		$Status
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
	#Region Construct Uri
	if($Status -eq 'played')
	{
		$RestEndpoint = ":/scrobble"
	}
	else
	{
		$RestEndpoint = ":/unscrobble"
	}

	$Params = [Ordered]@{
		identifier = 'com.plexapp.plugins.library'
		key        = $Id
	}

	$DataUri = Get-PlexAPIUri -RestEndpoint $RestEndpoint -Params $Params
	#EndRegion

	#############################################################################
	#Region Make Request
	if($PSCmdlet.ShouldProcess("Set watch status for item Id $Id to $Status"))
	{
		Write-Verbose -Message "Setting watch status for item Id $Id to $Status"
		try
		{
			Invoke-RestMethod -Uri $DataUri -Method "GET" | Out-Null
		}
		catch
		{
			throw $_
		}
	}
	#EndRegion
}