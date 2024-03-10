function Remove-PlexCollection
{
    <#
		.SYNOPSIS
			Removes a Plex collection.
		.DESCRIPTION
			Removes a Plex collection.
		.PARAMETER Id
			The Id of the collection to remove.
		.EXAMPLE
			Remove-PlexCollection -Id 12345
        .EXAMPLE
            Get-PlexCollection | Where-object {[int]$_.childCount -lt 5} | Select-Object -ExpandProperty ratingKey | Remove-PlexCollection
	#>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $Id
    )
    begin
    {
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
    }

    process
    {
        #############################################################################
        #Region Make request
        if ($PSCmdlet.ShouldProcess("Remove collection with Id '$Id'"))
        {
            Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Removing collection"
            try
            {
                $Uri = Get-PlexAPIUri -RestEndpoint "library/collections/$Id"
                Invoke-RestMethod -Uri $Uri -Method DELETE -ErrorAction Stop | Out-Null
            }
            catch
            {
                $PSCmdlet.WriteError($_)
            }
        }
        #EndRegion
    }
}