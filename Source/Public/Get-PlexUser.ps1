function Get-PlexUser
{
	<#
		.SYNOPSIS
			Gets a list of users associated with your account (e.g those you have shared with).
		.DESCRIPTION
			Gets a list of users associated with your account (e.g those you have shared with).
			This can include users who do not currently have access to libraries.
		.PARAMETER Username
			Refine by username (note: all users must be obtained from the Plex API first).
		.PARAMETER IncludeToken
			Get access token(s) that accounts use to access your server.
		.EXAMPLE
			Get-PlexUser
	#>

	[CmdletBinding(SupportsShouldProcess)]
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
	#Region Get data
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting all users"
	try
	{
		$Data = Invoke-RestMethod -Uri "https://plex.tv/api/users`?X-Plex-Token=$($DefaultPlexServer.Token)" -Method GET -ErrorAction Stop
		if($Data.MediaContainer.Size -eq 0)
		{
			return
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion

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
	#Region Filtering
	if($Username)
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Filtering by username"
		[array]$Results = $Data.MediaContainer.User | Where-Object { $_.username -eq $Username }
		if(!$Results)
		{
			throw "Username '$Username' not found."
		}
	}
	else
	{
		[array]$Results = $Data.MediaContainer.User
	}
	#EndRegion

	#############################################################################
	#Region Include access tokens
	if($IncludeToken)
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting access token(s)"

		# There isn't a way to selective query, so just get all user tokens:
		try
		{
			# Get all user tokens:
			$UserTokens = Get-PlexUserToken -MachineIdentifier $DefaultPlexServer.ClientIdentifier -ErrorAction Stop

			# On the token objects, repeat the logic earlier by setting username to equal title if username is null.
			# Subtly different this time because the property exists on the object returned so we don't *create* a new
			# noteproperty but just populate the existing one:
			$UserTokens | Where-Object { $_.username -eq "" } | ForEach-Object {
				$_.username = $_.title
			}

			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): $($UserTokens.count) user tokens received"
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
	#EndRegion

	#############################################################################
	# Append type and return results
	$Results | ForEach-Object { $_.psobject.TypeNames.Insert(0, "PSPlex.User") }
	return $Results
}