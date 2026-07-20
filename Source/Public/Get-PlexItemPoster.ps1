function Get-PlexItemPoster
{
	<#
		.SYNOPSIS
			Downloads the poster/thumbnail for one or more Plex items.
		.DESCRIPTION
			Downloads the poster/thumbnail for one or more Plex items to disk.
			Each poster is saved as <ratingKey>.jpg in the destination directory.
		.PARAMETER Item
			A Plex item (or array of items, e.g. from Get-PlexItem/Find-PlexItem) to get the poster for.
			Accepts pipeline input.
		.PARAMETER DestinationPath
			The directory to save the poster(s) to. Defaults to the current directory.
		.EXAMPLE
			# Download the poster for a single item:
			Get-PlexItem -Id 204 | Get-PlexItemPoster
		.EXAMPLE
			# Download posters for all items in a library to a specific folder:
			Get-PlexItem -LibraryTitle Films | Get-PlexItemPoster -DestinationPath 'C:\Posters'
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[PSCustomObject]
		$Item,

		[Parameter(Mandatory = $false)]
		[String]
		$DestinationPath = (Get-Location).Path
	)

	begin
	{
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
	}
	process
	{
		foreach($PlexItem in $Item)
		{
			#############################################################################
			#Region Get data
			$OutFile = Join-Path -Path $DestinationPath -ChildPath "$($PlexItem.ratingKey).jpg"
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting poster for item $($PlexItem.title) | $($PlexItem.ratingKey)"
			try
			{
				Invoke-PlexRequest -RestEndpoint $PlexItem.thumb -Method GET -OutFile $OutFile
			}
			catch
			{
				throw $_
			}
			#EndRegion
		}
	}
	end
	{

	}
}
