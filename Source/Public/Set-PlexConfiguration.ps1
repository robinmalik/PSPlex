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
		[Array]$OwnedAndOnline = $ResourceData | Where-Object { $_.product -eq 'Plex Media Server' -and $_.owned -eq 1 -and $_.presence -eq $True }
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
			<#
				When storing the configuration data for each server we need an accessible uri.
				Servers can have multiple connections defined in the .connections property.

				Example for a server where remote access is turned off:

				protocol : https
				address  : 192.168.0.100
				port     : 32400
				uri      : https://192-168-0-100.someidentifier.plex.direct:32400
				local    : True
				relay    : False
				IPv6     : False


				Example for a server with remote access enabled. Note the public IP address in the .connections.address property
				and multiple plex.direct uris:

				protocol : https
				address  : 172.17.0.5
				port     : 32400
				uri      : https://172-17-0-5.someidentifier.plex.direct:32400
				local    : True
				relay    : False
				IPv6     : False

				protocol : https
				address  : 219.153.56.22
				port     : 32400
				uri      : https://219-153-56-22.someidentifier.plex.direct:32400
				local    : False
				relay    : False
				IPv6     : False


				Example for a server where remote access is turned off but we are advertising a custom uri for discovery by clients
				Note the only way we can access this particular server if it's on another network, is via the custom uri (as this IP
				is an internal docker IP address).

				protocol : https
				address  : mydomain.com
				port     : 443
				uri      : https://mydomain.com:443
				local    : False
				relay    : False
				IPv6     : False

				protocol : https
				address  : 172.18.0.2
				port     : 32400
				uri      : https://172-18-0-2.someidentifier.plex.direct:32400
				local    : True
				relay    : False
				IPv6     : False

				There might be a more elegant way to select the connection we want but for now we'll go with this for a priority ordering:

				1)	A direct to the server connection (not via .plex.direct) that is secured with https via a domain name (not an IP address).
					Example: mydomain.com:443
				2)	A secured plex.direct connection. There could be multiple. Prioritise the non-local one but fallback to the local one if necessary.
				3)	A direct to the server connection (not via .plex.direct) that is not secured with https.
					Example: 192.168.0.100:32400
			#>

			$DirectToServerConnection = $Server.connections | Where-Object { $_.uri -notmatch "plex.direct" -and $_.uri -match "^https" -and $_.address -notmatch "(\d{1,3}\.){3}\d{1,3}" }
			if($DirectToServerConnection)
			{
				Write-Verbose -Message "Found a direct to server connection that is secured with https via a domain name: $($DirectToServerConnection.uri)"
				$Uri = $DirectToServerConnection.uri
				$Port = $DirectToServerConnection.port
			}
			else
			{
				[Array]$PlexDirectConnection = $Server.connections | Where-Object { $_.uri -match "plex.direct" }

				# If there are multiple plex.direct connections, prioritise the non-local one:
				$NonLocalPlexDirectConnection = $PlexDirectConnection | Where-Object { $_.local -eq $False }
				if($NonLocalPlexDirectConnection)
				{
					Write-Verbose -Message "Found a non-local plex.direct connection: $($NonLocalPlexDirectConnection.uri)"
					$Uri = $NonLocalPlexDirectConnection.uri
					$Port = $NonLocalPlexDirectConnection.port
				}
				else
				{
					$LocalPlexDirectConnection = $PlexDirectConnection | Where-Object { $_.local -eq $True }
					if($LocalPlexDirectConnection)
					{
						Write-Verbose -Message "Found a local plex.direct connection: $($LocalPlexDirectConnection.uri)"
						$Uri = $LocalPlexDirectConnection.uri
						$Port = $LocalPlexDirectConnection.port
					}
				}
			}


			if(!$Uri)
			{
				# We didn't find a suitable connection to use so skip this server
				Write-Verbose -Message "No suitable connection found for server $($Server.name). Skipping."
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