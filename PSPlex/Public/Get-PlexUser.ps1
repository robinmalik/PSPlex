function Get-PlexUser
{
	<#
		.SYNOPSIS
		Short description

		.DESCRIPTION
		Long description

		.PARAMETER Username
		Parameter description

		.PARAMETER IncludeToken
		Parameter description

		.EXAMPLE
		An example

		.NOTES
			The API at plex.tv/api will return XML, not JSON.
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $false)]
		[String]
		$Username,

		[Parameter(Mandatory = $false)]
		[Switch]
		$IncludeToken
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
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting all users"
	try
	{
		$global:Data = Invoke-RestMethod -Uri "https://plex.tv/api/users`?X-Plex-Token=$($DefaultPlexServer.Token)" -Method GET -ErrorAction Stop
		if($Data.MediaContainer.Size -eq 0)
		{
			return
		}
	}
	catch
	{
		throw $_
	}


	#############################################################################
	# Managed users have no username property (only title). As this module uses 'username', copy title to username:
	$Data.MediaContainer.User | Where-Object { $null -eq $_.username } | ForEach-Object {
		$_ | Add-Member -NotePropertyName 'username' -NotePropertyValue $_.title -Force
	}

	#############################################################################
	# It seems that migrating to JSON requests for data results in objects not possessing 'lastSeenAt'
	# as a top level property for each user. It's nested away, so let's get it and add it as a new property.
	# Hashing out as this property seems to be the same across all users, and don't understand that just yet.
	#$Data.MediaContainer.User | ForEach-Object {
	#	if($Null -ne $_.ChildNodes.lastSeenAt) { $_ | Add-Member -NotePropertyName 'lastSeenAt' -NotePropertyValue (ConvertFrom-UnixTime $_.ChildNodes.lastSeenAt) -Force }
	#}

	#############################################################################
	if($Username)
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Filtering by username"
		[array]$Results = $Data.MediaContainer.User | Where-Object { $_.username -eq $Username }
	}
	else
	{
		[array]$Results = $Data.MediaContainer.User
	}


	#############################################################################
	if($IncludeToken)
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting access token(s)"

		# There isn't a way to selective query, so just get all user tokens:
		try
		{
			$PlexServer = Get-PlexServer -Name $DefaultPlexServer.PlexServer -ErrorAction Stop
			$UserTokens = Get-PlexUserToken -MachineIdentifier $PlexServer.machineIdentifier -ErrorAction Stop
			Write-Verbose -Message "$($UserTokens.count) user tokens received"
		}
		catch
		{
			throw $_
		}

		# Append (somewhat inefficient with the where clause, but this is in the order of ms here):
		foreach($User in $Results)
		{
			$User | Add-Member -MemberType NoteProperty -Name 'token' -Value $($UserTokens | Where-Object { $_.username -eq $User.username }).token
		}
	}

	#############################################################################
	# Append type and return results
	$Results | ForEach-Object { $_.psobject.TypeNames.Insert(0, "PSPlex.User") }
	return $Results
}