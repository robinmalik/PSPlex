function Get-PlexAuthenticationToken
{
	<#
		.SYNOPSIS
			Gets the authentication token from Plex.tv for your account.
		.DESCRIPTION
			Gets the authentication token from Plex.tv for your account.
			Creates a script scoped variable that is used by the other functions.
		.PARAMETER Credential
			A PScredential object (usually obtained by running Get-Credential).
		.EXAMPLE
			Get-PlexAuthenticationToken -Credential (Get-Credential)
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $false)]
		[PSCredential]
		$Credential
	)

	if(!$Credential)
	{
		$Credential = Get-Credential
	}

	$Base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Credential.GetNetworkCredential().UserName, $Credential.GetNetworkCredential().Password)))

	try
	{
		$Data = Invoke-RestMethod -Uri "https://plex.tv/users/sign_in.json" -Method POST -Headers @{
			'Authorization'            = ("Basic {0}" -f $Base64AuthInfo);
			'X-Plex-Client-Identifier' = "PowerShell-Test";
			'X-Plex-Product'           = 'PowerShell-Test';
			'X-Plex-Version'           = "V0.01";
			'X-Plex-Username'          = $Credential.GetNetworkCredential().UserName;
		} -ErrorAction Stop

		$script:PlexServerData = [PSCustomObject]@{
			'Username' = $Data.user.username
			'Token'    = $Data.user.authentication_token
			'AddedOn'  = $(Get-Date -Format 's')
		}
	}
	catch
	{
		throw $_
	}
}