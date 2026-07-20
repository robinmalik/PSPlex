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
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'False Positive')]
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
			Import-PlexConfiguration
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
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Initiating metadata refresh for item Id $Id"
		try
		{
			Invoke-PlexRequest -RestEndpoint "library/metadata/$Id/refresh" -Method PUT | Out-Null
		}
		catch
		{
			throw $_
		}
	}
	#EndRegion
}