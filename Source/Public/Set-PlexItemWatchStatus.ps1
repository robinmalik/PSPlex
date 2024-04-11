function Set-PlexItemWatchStatus
{
	<#
		.SYNOPSIS
			Set the watch status for a Plex item.
		.DESCRIPTION
			Set the watch status for a Plex item.
		.PARAMETER Id
			Id of the item to set the watch status for.
		.PARAMETER Status
			Status to set the item to. Valid values are 'played' and 'unplayed'.
		.PARAMETER AlternativeToken
			Token for another user.
		.EXAMPLE
			Set-PlexItemWatchStatus -Id 1234 -Status played
		.EXAMPLE
			Set the watch status for item Id 1234 to 'played' for another user:
			$User = Get-PlexUser -Username 'username' -IncludeToken
			Set-PlexItemWatchStatus -Id 1234 -Status played -AlternativeToken $User.Token
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$Id,

		[Parameter(Mandatory = $true)]
		[ValidateSet('played', 'unplayed')]
		[String]
		$Status,

		[Parameter(Mandatory = $false)]
		[ValidateNotNullOrEmpty()]
		[String]
		$AlternativeToken
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

	if($AlternativeToken)
	{
		$Params.Add('X-Plex-Token', $AlternativeToken)
	}

	$DataUri = Get-PlexAPIUri -RestEndpoint $RestEndpoint -Params $Params
	#EndRegion

	#############################################################################
	#Region Make Request
	if($PSCmdlet.ShouldProcess("Set watch status for item Id $Id to $Status"))
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Setting watch status for item Id $Id to $Status"
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