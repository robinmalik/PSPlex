function Import-PlexConfiguration
{
	<#
		.SYNOPSIS
			Imports configuration from disk.
		.DESCRIPTION
			Imports configuration from disk.
			The aim of this function is to keep the config in a scoped variable for implicit use rather than expecting
			the user to pass details around. As such, nothing is explicitly returned from this function.
			It runs at the beginning of every function.
		.EXAMPLE
			Import-PlexConfiguration
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
	)

	#############################################################################
	# Set some defaults for all cmdlet calls
	$PSDefaultParameterValues["Import-PlexConfiguration:WhatIf"] = $false
	$PSDefaultParameterValues["Invoke-RestMethod:UseBasicParsing"] = $true
	$PSDefaultParameterValues["Invoke-RestMethod:Headers"] = @{"Accept" = "application/json, text/plain, */*" }
	$PSDefaultParameterValues["Invoke-RestMethod:ErrorAction"] = "Stop"
	$PSDefaultParameterValues["Invoke-WebRequest:UseBasicParsing"] = $true
	$PSDefaultParameterValues["Invoke-WebRequest:Headers"] = @{"Accept" = "application/json, text/plain, */*" }
	$PSDefaultParameterValues["Invoke-WebRequest:ErrorAction"] = "Stop"

	#############################################################################
	#Region Get path to the config file (varies by OS):
	try
	{
		$ConfigFile = Get-PlexConfigFileLocation -ErrorAction Stop
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#############################################################################
	if(Test-Path -Path $ConfigFile)
	{
		Write-Verbose -Message "Importing Configuration from $ConfigFile"
		try
		{
			$script:PlexConfigData = Get-Content -Path $ConfigFile -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
		}
		catch
		{
			throw $_
		}

		try
		{
			# Perform some file checking to be sure we can actually use it:

			# See if there is a default server set:
			$script:DefaultPlexServer = $script:PlexConfigData | Where-Object { $_.Default -eq $True }

			# If there's more than 1 default set then exit:
			if($script:DefaultPlexServer.Count -gt 1)
			{
				throw "You cannot have more than 1 default server. This shouldn't happen. Have you been manually editing the config file?: $ConfigFile"
			}

			# If there's no default server, and there's only 1 server in the config file set it as the default, save the file and then declare $script:DefaultPlexServer
			if(!$script:DefaultPlexServer -and $script:PlexConfigData.Count -eq 1)
			{
				$script:PlexConfigData.Default = $True
				Write-Warning -Message "Only 1 server defined in the configuration file. Default was set to false. Setting to true."
				ConvertTo-Json -InputObject @($script:PlexConfigData) -Depth 3 | Out-File -FilePath $ConfigFile -Force -ErrorAction Stop
				# Set the default server:
				$script:DefaultPlexServer = $script:PlexConfigData | Where-Object { $_.Default -eq $True }
			}

			# If there's no default server, and there's more than 1 server in the config file, exit:
			if(!$script:DefaultPlexServer -and $script:PlexConfigData.Count -gt 1)
			{
				throw "There are $($script:PlexConfigData.Count) servers configured but none are set to the default. This shouldn't happen. You can inspect the config file here: $ConfigFile"
			}
		}
		catch
		{
			throw $_
		}
	}
	else
	{
		throw 'No saved configuration information. Run Get-PlexAuthenticationToken, then Save-PlexConfiguration.'
	}
}