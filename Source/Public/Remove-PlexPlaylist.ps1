function Remove-PlexPlaylist
{
	<#
		.SYNOPSIS
			Remove a playlist from your or another user's account.
		.DESCRIPTION
			Remove a playlist from your or another user's account.
		.PARAMETER Id
			The Id of the playlist to remove.
		.PARAMETER AlternativeToken
			Alternative token to use for authentication. For example,
			when querying for playlists for a different user.
		.EXAMPLE
			Remove-PlexPlaylist -Id 12345
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$Id,

		[Parameter(Mandatory = $false)]
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
	#Region Make request
	if($PSCmdlet.ShouldProcess("Remove playlist with Id '$Id'"))
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Removing playlist"
		try
		{
			if($AlternativeToken)
			{
				$Params = @{'X-Plex-Token' = $AlternativeToken }
			}
			$Uri = Get-PlexAPIUri -RestEndpoint "playlists/$Id" -Params $Params
			Invoke-RestMethod -Uri $Uri -Method DELETE -ErrorAction Stop | Out-Null
		}
		catch
		{
			throw $_
		}
	}
	#EndRegion
}