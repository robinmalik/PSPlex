function Get-PlexShare
{
	<#
		.SYNOPSIS
			Gets a user and the share status of your libraries with them.

		.DESCRIPTION
			Gets a user and the share status of your libraries with them.

		.PARAMETER Username
			The username of the user to query share status.

		.PARAMETER Email
			The email address of the user to query share status.

		.EXAMPLE
			Get-PlexShare -Username "username"

		.EXAMPLE
			# Get share status for a single user:
			Get-PlexShare -Username "username" | Select -ExpandProperty section

		.EXAMPLE
			# Get share status for all users:
			Get-PlexUser | Select username | % { Get-PlexShare -Username $_.username }

		.OUTPUTS
			username allowSync section                                 invitedAt
			-------- --------- -------                                 ---------
			person1  1         {Section, Section, Section, Section...} 16/01/2022 19:01:39
			person2  0         {Section, Section, Section, Section...} 08/01/2022 20:15:31
	#>

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