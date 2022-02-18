function Get-PlexShare
{
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $false)]
		[String]
		$Username
	)

	#############################################################################
	#Region Import Plex Configuration
	try
	{
		Import-PlexConfiguration
		$DefaultPlexServer = $PlexConfigData | Where-Object { $_.Default -eq $True }
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#############################################################################
	#Region Get Server Details from Plex.tv (to obtain machine identifier)
	try
	{
		$Servers = Get-PlexServer -ErrorAction Stop
		if(!$Servers)
		{
			throw "No servers? This is odd..."
		}

		$Server = $Servers | Where-Object { $_.Name -eq $DefaultPlexServer.PlexServer }
		if(!$Server)
		{
			throw "Could not match the current default Plex server ($($DefaultPlexServer.PlexServer)) to those returned from plex.tv"
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion


	#############################################################################
	try
	{
		$global:Data = Invoke-RestMethod -Uri "https://plex.tv/api/servers/$($Server.machineIdentifier)/shared_servers`?`X-Plex-Token=7U3PLsL3XHwVhw_q47B7" -Method GET -ErrorAction Stop
		if($Data.MediaContainer.Size -eq 0)
		{
			return
		}

		#############################################################################
		# Managed users have no username property - not sure how best to handle this.
	}
	catch
	{
		throw $_
	}


	#############################################################################
	if($Username)
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Filtering by username"
		[array]$Results = $Data.MediaContainer.SharedServer | Where-Object { $_.username -eq $Username }
	}
	else
	{
		[array]$Results = $Data.MediaContainer.SharedServer
	}


	#############################################################################
	# Append type and return results
	$Results | ForEach-Object { $_.psobject.TypeNames.Insert(0, "PSPlex.SharedLibrary") }
	return $Results
}