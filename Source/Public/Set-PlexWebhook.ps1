function Set-PlexWebhook
{
	<#
		.SYNOPSIS
			Sets a URL for your Plex server to use for webhooks.
		.DESCRIPTION
			Sets a URL for your Plex server to use for webhooks.
		.PARAMETER Url
			The URL endpoint to receive your Plex webhooks
		.EXAMPLE
			Set-PlexWebhook -Url https://myserver.domain.com/plex
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param (
		[ValidateScript(
			{
				if($null -ne ([System.URI]$_).AbsoluteURI)
				{
					$True
				}
				Else
				{
					throw "$_ is not a valid Url"
				} })]
		[String]$Url
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
	$string = "urls[]=" + $Url
	Add-Type -AssemblyName System.Web
	$stringencoded = [System.Web.HttpUtility]::UrlEncode($string)
	$stringencoded = $stringencoded -replace '%3d', '='

	$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
	$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36"

	if($PSCmdlet.ShouldProcess($DefaultPlexServer.PlexServer, "Set webhook to $Url"))
	{
		Invoke-WebRequest -UseBasicParsing -Uri "https://plex.tv/api/v2/user/webhooks?X-Plex-Token=$($DefaultPlexServer.Token)" `
			-Method POST `
			-WebSession $session `
			-ContentType "application/x-www-form-urlencoded; charset=UTF-8" `
			-Body $stringencoded
	}
	#EndRegion
}