function Get-PlexShare
{
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $false, ParameterSetName = 'username')]
		[String]
		$Username,

		[Parameter(Mandatory = $false, ParameterSetName = 'email')]
		[String]
		$Email
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
	#Region Get data
	try
	{
		$Data = Invoke-RestMethod -Uri "https://plex.tv/api/servers/$($Server.machineIdentifier)/shared_servers`?`X-Plex-Token=$($DefaultPlexServer.Token)" -Method GET -ErrorAction Stop
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
	#EndRegion

	#############################################################################
	#Region Filter by username or email
	if($Username -or $Email)
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Filtering by $($PsCmdlet.ParameterSetName)"
		[array]$Results = $Data.MediaContainer.SharedServer | Where-Object { $_."$($PsCmdlet.ParameterSetName)" -eq $($PSBoundParameters[$PsCmdlet.ParameterSetName]) }
		if(!$Results)
		{
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): No results found for specified username"
			return
		}
	}
	else
	{
		[array]$Results = $Data.MediaContainer.SharedServer
	}
	#EndRegion

	#############################################################################
	# Append type and return results
	$Results | ForEach-Object { $_.psobject.TypeNames.Insert(0, "PSPlex.SharedLibrary") }
	return $Results
}