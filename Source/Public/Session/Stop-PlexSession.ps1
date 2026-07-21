function Stop-PlexSession
{
	<#
		.SYNOPSIS
			Stops a Plex session.
		.DESCRIPTION
			Stops a Plex session, either by id or by passing the results of Get-PlexSession
			to -SessionObject.
		.PARAMETER Id
			The session id to stop.
		.PARAMETER SessionObject
			The session object, if piping.
		.PARAMETER Reason
			Optional reason for stopping the session. Will be shown to the streamer.
		.EXAMPLE
			$Session = Get-PlexSession (assumes only 1 stream)
			Stop-PlexSession -Id $Session.Session.id
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true, ParameterSetName = 'SessionId')]
		[String]$Id,

		[Parameter(Mandatory = $true, ParameterSetName = 'SessionObject', ValueFromPipeline = $true)]
		$SessionObject,

		[Parameter(Mandatory = $false)]
		[String]$Reason = 'Message your Plex contact, or try again later!'
	)

	begin
	{

		#############################################################################
		#Region Import Plex Configuration
		if(!$script:PlexConfigData)
		{
			try
			{
				Import-PlexConfiguration
			}
			catch
			{
				throw $_
			}
		}
		#EndRegion

		# If the user passed an Id, create an object using the same structure as the session object
		if($PSCmdlet.ParameterSetName -eq 'SessionId')
		{
			[Array]$SessionObject = [PSCustomObject]@{
				Session = @{
					Id = $Id
				}
			}
		}
	}
	process
	{
		foreach($Session in $SessionObject)
		{
			if($PSCmdlet.ShouldProcess($Session.Session.Id, 'Stop Plex Session'))
			{
				Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Terminating session: $($Session.Session.Id) with reason: $Reason"
				try
				{
					$RestEndpoint = "status/sessions/terminate"
					$Params = [Ordered]@{
						reason    = $Reason
						sessionId = $Session.Session.Id
					}
					# A successful termination returns nothing from the API
					Invoke-PlexRequest -RestEndpoint $RestEndpoint -Params $Params -Method GET
				}
				catch
				{
					throw $_
				}
			}
		}
	}
	end
	{
	}
}