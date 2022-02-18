function Stop-PlexSession
{
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

		$RestEndpoint = "status/sessions/terminate"

		# If the user passed an ID, create an object using the same structure as the session object
		if($PSCmdlet.ParameterSetName -eq 'SessionId')
		{
			[Array]$SessionObject = [PSCustomObject]@{
				Session = @{
					Id = $Id
				}
			}
		}
		else
		{
		}
	}
	process
	{
		foreach($Session in $SessionObject)
		{
			Write-Verbose -Message "Terminating session: $($Session.Id)"
			try
			{
				# A successful termination returns nothing from the API
				Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/$RestEndpoint`?`X-Plex-Token=$($DefaultPlexServer.Token)&reason=$Reason&sessionId=$($Session.Session.Id)" -Method GET -ErrorAction Stop
			}
			catch
			{
				throw $_
			}
		}
	}
	end
	{
	}
}