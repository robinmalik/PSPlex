function Get-PlexItemPoster
{
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ParameterSetName = 'Id', ValueFromPipeline = $true)]
		[PSCustomObject]
		$Item
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
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting poster for item $($PlexItem.title) | $($PlexItem.ratingKey)"
			try
			{
				Invoke-PlexRequest -RestEndpoint $PlexItem.thumb -Method GET -OutFile "$($PlexItem.ratingKey).jpg"
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
