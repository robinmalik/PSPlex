function Get-PlexUserToken
{
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$MachineIdentifier,

		[Parameter(Mandatory = $false)]
		[String]
		$Username
	)

	# Use the machine Id to get the Server Access Tokens for the users:
	try
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting all access tokens for server $MachineIdentifier"
		$Data = Invoke-RestMethod -Uri "https://plex.tv/api/servers/$($MachineIdentifier)/access_tokens.xml?auth_token=$($DefaultPlexServer.Token)&includeProfiles=1&includeProviders=1" -ErrorAction Stop
		<#
			Example user object:

				token                : their-server-access-token
				username             : their-username
				thumb                : https://plex.tv/users/jkh324jkh234jh23/avatar?c=4353453454
				title                : their-email@domain.com
				id                   : 18658724
				owned                : 0
				allow_sync           : 0
				allow_camera_upload  : 0
				allow_channels       : 0
				allow_tuners         : 0
				allow_subtitle_admin : 0
				filter_all           :
				filter_movies        :
				filter_music         :
				filter_photos        :
				filter_television    :
				scrobble_types       :
				profile_settings     : profile_settings
				library_section      : {library_section, library_section, library_section}


			Despite the singular example, the data can vary depending on how the user signed up.
			We may find that title/username is a typical username.
			We may find that title/username is the same as the email.
			We may find that for a managed user, they won't have a username or email but only 'title'.

				title                       username                email
				-----                       --------                -----
				mycleverusername            mycleverusername        someperson@hotmail.com
				anotheruser@gmail.com       anotheruser@gmail.com   anotheruser@gmail.com
				manageduser

			In order to cater to managed users, we will effectively use the title, as username.

			Note: It's entirely possible that there could be a managed user with the same username
			as a normal user. It's unlikely, but possible. This should be handled by downstream code.

		#>

		if($Username)
		{
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Filtering by username/title"
			$Data.access_tokens.access_token | Where-Object { $_.username -eq $Username -or $_.title -eq $Username }
			return
		}
		else
		{
			return $Data.access_tokens.access_token
		}
	}
	catch
	{
		throw $_
	}
}