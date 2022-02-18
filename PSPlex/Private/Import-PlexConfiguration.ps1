

function Import-PlexConfiguration
{
	<#
		.SYNOPSIS
			Imports configuration from disk.
		.DESCRIPTION
			Imports configuration from disk.
			The aim of this function is to keep the config in a scoped variable for implicit use rather than expecting
			the user to pass details around. As such, nothing is explicitly returned from this function.
		.EXAMPLE
			Import-PlexConfiguration
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
	)

	#############################################################################
	# Set some defaults for all cmdlet calls
	$PSDefaultParameterValues["Invoke-RestMethod:UseBasicParsing"] = $true
	$PSDefaultParameterValues["Invoke-RestMethod:Headers"] = @{"Accept" = "application/json, text/plain, */*" }
	$PSDefaultParameterValues["Invoke-RestMethod:ErrorAction"] = "Stop"
	$PSDefaultParameterValues["Invoke-WebRequest:UseBasicParsing"] = $true
	$PSDefaultParameterValues["Invoke-WebRequest:Headers"] = @{"Accept" = "application/json, text/plain, */*" }
	$PSDefaultParameterValues["Invoke-WebRequest:ErrorAction"] = "Stop"

	#############################################################################
	# Path to the config file varies on OS. Get the location:
	try
	{
		$ConfigFile = Get-PlexConfigFileLocation -ErrorAction Stop
	}
	catch
	{
		throw $_
	}

	#############################################################################
	# Known issue that this will not work on Linux/MacOS. Will adapt later.
	if(Test-Path -Path $ConfigFile)
	{
		Write-Verbose -Message "Importing configuration from $ConfigFile"
		try
		{
			$global:PlexConfigData = Get-Content -Path $ConfigFile -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop

			# A few checks on the config:
			$DefaultPlexServer = $global:PlexConfigData | Where-Object { $_.Default -eq $True }
			if(!$DefaultPlexServer)
			{
				throw "No default server defined in the configuration file: $ConfigFile"
			}

			if($DefaultPlexServer.Count -gt 1)
			{
				throw "You cannot have more than 1 default server. This shouldn't happen. Have you been manually editing the config file?: $ConfigFile"
			}
		}
		catch
		{
			throw $_
		}

		# If Windows, select the default server and decode the token:
		if($IsWindows -or ([version]$PSVersionTable.PSVersion -lt [version]"5.99.0" ))
		{
			$DefaultPlexServer.Token = $(
				$SP = ConvertTo-SecureString -String $DefaultPlexServer.Token
				$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SP)
				[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
			)
		}
	}
	else
	{
		throw 'No saved configuration information. Run Get-PlexAuthenticationToken, then Save-PlexConfiguration.'
	}
}