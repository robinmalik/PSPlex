function Get-PlexConfigFileLocation
{
	<#
		.SYNOPSIS
			Returns config file location.
		.DESCRIPTION
			Returns config file location.
	#>

	[CmdletBinding()]
	[OutputType([System.String])]
	param(
	)

	$FileName = 'PSPlexConfig.json'

	# PowerShell Core has IsWindows, IsLinux, IsMac, but previous versions do not:
	if($IsWindows -or ( [version]$PSVersionTable.PSVersion -lt [version]"5.99.0" ))
	{
		return "$env:appdata\PSPlex\$FileName"
	}
	elseif($IsLinux -or $IsMacOS)
	{
		return "$HOME/.PSPlex/$FileName"
	}
	else
	{
		throw "Unknown Platform"
	}
}