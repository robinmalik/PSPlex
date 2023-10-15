function Set-PlexDefaultServer
{
	<#
		.SYNOPSIS
			Set the default Plex server.
		.DESCRIPTION
			Set the default Plex server.
		.PARAMETER Name
			Name of the server to set as default.
		.EXAMPLE
			An example
		.NOTES
			General notes
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$Name
	)

	#Region Save Configuration to disk
	try
	{
		$ConfigFile = Get-PlexConfigFileLocation -ErrorAction Stop
		if((Test-Path -Path $ConfigFile) -eq $False)
		{
			throw "No config file found. You should run Set-PlexConfiguration to create one."
		}
		else
		{
			Import-PlexConfiguration

			# If the server name is not in the config file, throw an error:
			if($script:PlexConfigData.PlexServer -notcontains $Name)
			{
				throw "The server name '$Name' does not match any of the servers in the config file. If this is unexpected, make sure all servers are remotely accessible and run Set-PlexConfiguration to update the config file."
			}

			# If the server name is already the default, return:
			if($script:PlexConfigData | Where-Object { $_.PlexServer -eq $Name -and $_.Default -eq $True })
			{
				Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Server '$Name' is already the default server."
				return
			}

			# Else we have to set the new default server:
			# Loop through the config data and set the default to $false for all servers, but set the default to $true for the server we want to be default:
			$script:PlexConfigData | ForEach-Object {
				if($_.PlexServer -eq $Name)
				{
					$_.Default = $true
				}
				else
				{
					$_.Default = $false
				}
			}

			# Save the config file:
			ConvertTo-Json -InputObject @($script:PlexConfigData) -Depth 3 | Out-File -FilePath $ConfigFile -Force -ErrorAction Stop

			# Remove the existing config data from memory (to force a reload next time a function call is made):
			Remove-Variable -Name PlexConfigData -Scope Script -Force

			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Default Plex server set to '$Name'."
		}
	}
	catch
	{
		throw $_
	}
}