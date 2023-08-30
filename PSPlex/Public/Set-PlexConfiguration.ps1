function Set-PlexConfiguration
{
	<#
		.SYNOPSIS
		.DESCRIPTION
		.PARAMETER Credential
		.EXAMPLE
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[PSCredential]
		$Credential,

		[Parameter(Mandatory = $true)]
		[String]
		$DefaultServerName
	)


	#Region Get auth token:
	try
	{
		$Base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Credential.GetNetworkCredential().UserName, $Credential.GetNetworkCredential().Password)))
		$Data = Invoke-RestMethod -Uri "https://plex.tv/users/sign_in.json" -Method POST -Headers @{
			'Authorization'            = ("Basic {0}" -f $Base64AuthInfo);
			'X-Plex-Client-Identifier' = "PowerShell-Test";
			'X-Plex-Product'           = 'PowerShell-Test';
			'X-Plex-Version'           = "V0.01";
			'X-Plex-Username'          = $Credential.GetNetworkCredential().UserName;
		} -ErrorAction Stop
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#Region Get online servers
	try
	{
		$ResourceData = Invoke-RestMethod -Uri "https://plex.tv/api/v2/resources?includeHttps=1&X-Plex-Token=$($Data.user.authentication_token)&X-Plex-Client-Identifier=PSPlex" -Method GET -UseBasicParsing -Headers @{"Accept" = "application/json, text/plain, */*" }
		if(!$ResourceData)
		{
			throw "Could not get resource data."
		}

		# Refine to only servers that are online and owned by the user:
		[Array]$OwnedAndOnline = $ResourceData | Where-Object { $_.product -eq 'Plex Media Server' -and $_.owned -eq 1 }
		if(!$OwnedAndOnline)
		{
			throw "No owned servers online."
		}

		# If in the owned and online servers, there's no match for $DefaultServerName, throw an error:
		if($OwnedAndOnline.Name -notcontains $DefaultServerName)
		{
			throw "The server name '$DefaultServerName' does not match any of the owned and online servers."
		}

		# Loop and construct a custom object to store in our configuration file.
		$ConfigurationData = [System.Collections.ArrayList]@()
		foreach($Server in $OwnedAndOnline)
		{
			# When storing the configuration data for each server, we need an accessible uri.

			# In the .connections property there may be an array of objects each with an 'address' property.
			# Find an address where it's a public IP address and 'uri' matches 'plex.direct':
			$Connection = $Server.connections | Where-Object { $_.address -notmatch '(^127\.)|(^192\.168\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)' -and $_.uri -match "plex.direct" }
			if(!$Connection)
			{
				# We didn't find a suitable Plex.direct connection to use so skip this server
				continue
			}

			# If the current server name is equal to $DefaultServerName, set the 'Default' property to $true
			if($Server.name -eq $DefaultServerName)
			{
				$Default = $true
			}
			else
			{
				$Default = $false
			}

			$ConfigurationData.Add(
				[PSCustomObject]@{
					PlexServer       = $Server.name
					Port             = $Connection.port
					PublicAddress    = $Server.publicAddress
					ClientIdentifier = $Server.clientIdentifier
					Token            = $Server.accessToken
					Uri              = $Connection.uri
					Default          = $Default
				}) | Out-Null
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#Region Save Configuration to disk
	try
	{
		$ConfigFile = Get-PlexConfigFileLocation -ErrorAction Stop
		# Create folder:
		if(-not (Test-Path (Split-Path $ConfigFile)))
		{
			New-Item -ItemType Directory -Path (Split-Path $ConfigFile) | Out-Null
		}

		ConvertTo-Json -InputObject @($ConfigurationData) -Depth 3 -ErrorAction Stop | Out-File -FilePath $ConfigFile -Force -ErrorAction Stop
	}
	catch
	{
		throw $_
	}
	#EndRegion
}