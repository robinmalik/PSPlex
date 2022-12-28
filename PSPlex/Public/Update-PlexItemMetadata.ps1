function Update-PlexItemMetadata
{
	<#
		.SYNOPSIS
			Update the metadata for a Plex item.
		.DESCRIPTION
			Update the metadata for a Plex item.
		.PARAMETER Id
			The id of the item to update.
		.EXAMPLE
			Update-PlexItemMetadata -Id 54321
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$Id
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
	#Region Make request
	if($PSCmdlet.ShouldProcess("Update metadata for item $Id"))
	{
		Write-Verbose -Message "Initiating metadata refresh for item Id $Id"
		try
		{
			$Uri = Get-PlexAPIUri -RestEndpoint "library/metadata/$Id/refresh"
			Invoke-RestMethod -Uri $Uri -Method PUT | Out-Null
		}
		catch
		{
			throw $_
		}
	}
	#EndRegion
}