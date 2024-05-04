function Set-PlexConfiguration
{
	<#
		.SYNOPSIS
			Obtains an access token for your account and saves it and your server details.
		.DESCRIPTION
			Used to save Plex configuration to disk, which is used by all other functions.
		.PARAMETER Credential
			Credential object containing your Plex username and password.
		.EXAMPLE
			Set-PlexConfiguration -Credential (Get-Credential)
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
	Write-Verbose -Message "Getting authentication token"
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
	Write-Verbose -Message "Getting list of accessible servers"
	try
	{
		$ResourceData = Invoke-RestMethod -Uri "https://plex.tv/api/v2/resources?includeHttps=1&X-Plex-Token=$($Data.user.authentication_token)&X-Plex-Client-Identifier=PSPlex" -Method GET -UseBasicParsing -Headers @{"Accept" = "application/json, text/plain, */*" }
		if(!$ResourceData)
		{
			throw "Could not get resource data."
		}

		Write-Verbose -Message "The following servers were returned: $(($ResourceData.name | Sort-Object) -join ", ")"

		# Refine to only servers that are online and owned by the user:
		Write-Verbose -Message "Refining to only owned and online servers."
		[Array]$OwnedAndOnline = $ResourceData | Where-Object { $_.product -eq 'Plex Media Server' -and $_.owned -eq 1 }
		if(!$OwnedAndOnline)
		{
			throw "No owned servers online."
		}

		Write-Verbose -Message "The following servers are owned and online: $(($OwnedAndOnline.name | Sort-Object) -join ", ")"

		# If in the owned and online servers, there's no match for $DefaultServerName, throw an error:
		if($OwnedAndOnline.Name -notcontains $DefaultServerName)
		{
			throw "The server name '$DefaultServerName' does not match any of the owned and online servers."
		}

		# Loop and construct a custom object to store in our configuration file.
		$ConfigurationData = [System.Collections.ArrayList]@()
		foreach($Server in $OwnedAndOnline)
		{
			# When storing the configuration data for each server we need an accessible uri.
			# For servers with a public IP address in the .connections.address property, we can use the
			# .connections.uri property; this will be an address of the format:
			# https://<public-ip>.someidentifier.plex.direct:32400

			# For servers without a public IP in the .connections.address property, this suggests remote
			# access is turned off. Instead we can construct a locally accessible uri from the following
			# properties: "http://" + .connections.address + ":" + .connections.port
			# Note: From my testing even though .connections.protocol is https, it's still accessible over
			# http and we won't have to do any insecure certificate bypassing.

			# Note also: .connections.local is useful to show public/private addresses but we can't use it
			# otherwise we may end up with duplicate entries in the configuration file (one with IP, one with hostname)

			# .connections property could be an array of objects each with an 'address' property.
			# Find an address where it's a public IP address and 'uri' matches 'plex.direct':
			$PublicConnection = $Server.connections | Where-Object { $_.address -notmatch '(^127\.)|(^192\.168\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)' -and $_.uri -match "plex.direct" }
			if($PublicConnection)
			{
				$Uri = $PublicConnection.uri
				$Port = $PublicConnection.port
			}
			else
			{
				# Look for a private connection:
				$PrivateConnection = $Server.connections | Where-Object { $_.address -match '(^127\.)|(^192\.168\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)' }
				if($PrivateConnection)
				{
					$Uri = "http://$($PrivateConnection.address):$($PrivateConnection.port)"
					$Port = $PrivateConnection.port
				}
			}

			if(!$Uri)
			{
				# We didn't find a suitable connection to use so skip this server
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

			Write-Verbose -Message "Adding server $($Server.name) to configuration data."
			$ConfigurationData.Add(
				[PSCustomObject]@{
					PlexServer       = $Server.name
					Port             = $Port
					PublicAddress    = $Server.publicAddress
					ClientIdentifier = $Server.clientIdentifier
					Token            = $Server.accessToken
					Uri              = $Uri
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
	if($ConfigurationData.Count -gt 0)
	{
		try
		{
			$ConfigFile = Get-PlexConfigFileLocation -ErrorAction Stop

			# Create folder if it doesn't exist:
			if(-not (Test-Path (Split-Path $ConfigFile)))
			{
				New-Item -ItemType Directory -Path (Split-Path $ConfigFile) | Out-Null
			}

			# Write the configuration data to disk:
			ConvertTo-Json -InputObject @($ConfigurationData) -Depth 3 -ErrorAction Stop | Out-File -FilePath $ConfigFile -Force -ErrorAction Stop
		}
		catch
		{
			throw $_
		}
	}
	else
	{
		throw "No servers found."
	}
	#EndRegion
}