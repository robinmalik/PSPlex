function Save-PlexConfiguration
{
	<#
		.SYNOPSIS
			After executing 'Get-PlexAuthenticationToken', save your configuration to disk.
		.DESCRIPTION
			After executing 'Get-PlexAuthenticationToken', save your configuration to disk.
		.PARAMETER PlexServer
			The name of the Plex server.
		.PARAMETER PlexServerHostname
			The fully qualified hostname for your server.
		.PARAMETER Protocol
			The protocol (http/https)
		.PARAMETER Port
			The port (usually 32400)
		.PARAMETER Username
			Specify the username manually (if not running 'Get-PlexAuthenticationToken')
		.PARAMETER Token
			Specify the token manually (if not running 'Get-PlexAuthenticationToken')
		.PARAMETER Default
			Set the Plex server as the default. If this is the first time you're saving
			configuration it will be marked as the default.
		.EXAMPLE
			Save-PlexConfiguration -PlexServer myserver -PlexServerHostname namaste.yourdomain.com -Protocol https -Port 32400
	#>

	[CmdletBinding(DefaultParameterSetName = 'TokenFromGetPlexAuthenticationToken')]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$PlexServer,

		[Parameter(Mandatory = $true)]
		[String]
		$PlexServerHostname,

		[Parameter(Mandatory = $true)]
		[ValidateSet('http', 'https')]
		[String]
		$Protocol,

		[Parameter(Mandatory = $false)]
		[Int]
		$Port = 32400,

		[Parameter(Mandatory = $false, ParameterSetName = "TokenFromCommandLine")]
		[String]
		$Username,

		[Parameter(Mandatory = $false, ParameterSetName = "TokenFromCommandLine")]
		[String]
		$Token,

		[Parameter(Mandatory = $false)]
		[Switch]
		$Default
	)

	#############################################################################
	# If we're manually specifying a username/token:
	if($PSCmdlet.ParameterSetName -eq 'TokenFromCommandLine')
	{
		Write-Verbose -Message "Creating new PlexServerData construct with manually specified username and token"
		$script:PlexServerData = [PSCustomObject]@{
			'Username' = $Username
			'Token'    = $Token
			'AddedOn'  = $(Get-Date -Format 's')
		}
	}
	elseif(!$script:PlexServerData)
	{
		throw "No authentication token. Please run Get-PlexAuthenticationToken first, then re-run this function."
	}
	else
	{
		# $script:PlexServerData should be set :)
	}

	#############################################################################
	# Append additional data:
	$script:PlexServerData | Add-Member -MemberType NoteProperty -Name 'PlexServer' -Value $PlexServer -Force
	$script:PlexServerData | Add-Member -MemberType NoteProperty -Name 'PlexServerHostname' -Value $PlexServerHostname -Force
	$script:PlexServerData | Add-Member -MemberType NoteProperty -Name 'Protocol' -Value $Protocol -Force
	$script:PlexServerData | Add-Member -MemberType NoteProperty -Name 'Port' -Value $Port -Force


	#############################################################################
	#Region Create a folder to store the configuration file if required
	try
	{
		# Path to the config file varies on OS. Get the location:
		$ConfigFile = Get-PlexConfigFileLocation -ErrorAction Stop

		# Create folder:
		if(-not (Test-Path (Split-Path $ConfigFile)))
		{
			New-Item -ItemType Directory -Path (Split-Path $ConfigFile) | Out-Null
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion Create a folder to store the configuration file if required


	#############################################################################
	#Region Import existing configuration file
	try
	{
		# If found, $script:PlexConfigData will exist. Else error.
		Import-PlexConfiguration -ErrorAction Stop -Verbose:$VerbosePreference
		$ConfigExists = $true
		Write-Verbose -Message "Plex configuration file already exists."
	}
	catch
	{
		# No configuration file was imported. This is ok, as we'll create it later.
		$Error.Remove($Error[0])
	}
	#EndRegion Import existing configuration file


	#############################################################################
	#Region Encrypt token
	try
	{
		# Encrypt the token if we can:
		if($IsWindows -or ( [version]$PSVersionTable.PSVersion -lt [version]"5.99.0" ))
		{
			$Token = ($(ConvertTo-SecureString -String $script:PlexServerData.Token -AsPlainText -Force -ErrorAction Stop) | ConvertFrom-SecureString -ErrorAction Stop)
		}
		elseif($IsLinux -or $IsMacOS)
		{
			Write-Warning -Message "Plex Authentication Token will be stored in plain text $ConfigFile until encrypted methods are supported."
			$Token = $script:PlexServerData.Token
		}
		else
		{
			throw "Unknown Platform"
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion Encrypt token


	#############################################################################
	# Region Create/Append data structure to store in config file
	if($ConfigExists)
	{
		# If we were able to import config, we need to make sure we store additional details in the file properly.
		# A few things to consider:
		# 1) Duplicate entries - prevent this, with overwrite existing being the default action.
		# 2) Switching of the default server

		# Handle duplicate entries:
		if($PlexConfigData.PlexServer -contains $PlexServer)
		{
			Write-Warning -Message "Data for Plex server '$PlexServer' already exists. This will be overwritten."
			# Filter the already existing data out, overwriting $PlexConfigData. Make sure it remains an array, though:
			[Array]$PlexConfigData = $PlexConfigData | Where-Object { $_.PlexServer -ne $PlexServer }
		}

		# Handle default server:
		# Check if there is an existing default in the configuration:
		$DefaultServer = $PlexConfigData | Where-Object { $_.Default -eq $true }
		if($DefaultServer)
		{
			# If this function has been called with -Default:
			if($Default.IsPresent)
			{
				Write-Warning -Message "$PlexServer will be the new default for Plex queries (changing from: $($DefaultServer.PlexServer)"
				# Set current default server to false:
				$DefaultServer.Default = $false
			}
			else
			{
				Write-Warning -Message "Save-PlexConfiguration called without -Default, so $($DefaultServer.PlexServer) will remain the default server."
			}
		}
		else
		{
			# This would be an odd scenario but if the config (file) exists, there is no default server currently,
			# this is the only server, and the user hasn't specified -Default when calling this function, set it:
			if($PlexConfigData.Count -eq 1)
			{
				if(!$Default.IsPresent)
				{
					$Default = $True
				}
			}
		}

		# Create a new object with the required data:
		$AdditionalConfig = [PSCustomObject]@{
			'Username'           = $script:PlexServerData.username
			'Token'              = $Token
			'PlexServer'         = $PlexServer
			'PlexServerHostname' = $PlexServerHostname
			'Protocol'           = $Protocol
			'Port'               = $Port
			'Default'            = $Default.IsPresent
		}

		# Add this to the existing data:
		$PlexConfigData += $AdditionalConfig
	}
	else
	{
		# Create a new object with the required data:
		$script:PlexConfigData = @(
			[PSCustomObject]@{
				'Username'           = $script:PlexServerData.username
				'Token'              = $Token
				'PlexServer'         = $PlexServer
				'PlexServerHostname' = $PlexServerHostname
				'Protocol'           = $Protocol
				'Port'               = $Port
				'Default'            = $True
			}
		)
	}


	#############################################################################
	# Save to disk:
	try
	{
		ConvertTo-Json -InputObject $PlexConfigData | Out-File -FilePath $ConfigFile -Force -ErrorAction Stop
		Start-Sleep -Milliseconds 500
		Import-PlexConfiguration
	}
	catch
	{
		throw $_
	}
}