# About

This project started out as a script to copy a playlist from my account as a Plex Server owner to another user's account (on the same server). Slowly it got broken up into separate functions and became a simple PowerShell module.

# Getting Started:

1. Install the module from the PowerShell Gallery: `Install-Module -Name PSPlex`.
2. Run `Get-PlexAuthenticationToken`. You will be prompted to enter your Plex account name and password.
3. Run `Save-PlexConfiguration` and provide your Plex server name, the Plex hostname, protocol and port.
    * Example: `Save-PlexConfiguration -PlexServer myserver -PlexServerHostname namaste.yourdomain.com -protocol https -port 32400`

# Examples:

**Get a list of users with access to your server:**

`Get-PlexUser`

**Get a user and their access token:**

`$User = Get-PlexUser -Username 'yourfriend@theiremail.com -IncludeToken`
`$User.Token`

**Copy a playlist from your account to another account (e.g. a friend you have shared content with):**

`Copy-PlexPlaylist -PlaylistName 'Family' -Username 'yourfriend@theiremail.com' -verbose`

**Copy *all* playlists from your account to another account:**

`Get-PlexPlaylist | Foreach-Object { Copy-PlexPlaylist -PlaylistName $_.title -Username 'yourfriend@theiremail.com' }`

**Copy a single playlist to *all* users:**

`$Users = Get-PlexUser`
`$Users | Foreach-Object { Copy-PlexPlaylist -PlaylistName 'Family' -Username $_.username }`

**Remove a playlist for your account:**

`Remove-PlexPlaylist -ID 12345`

**Remove a playlist for a different account:**

`$User = Get-PlexUser -Username 'yourfriend@theiremail.com -IncludeToken`
`Remove-PlexPlaylist -ID 54321 -AlternativeToken $User.Token`

**Get collections and show only the title and ID:**

`Get-PlexCollection | select title,key`

**Stop sessions where Safari is being used:**

`Get-PlexSession | Where-Object { $_.Player.platform -eq 'Safari' } | Stop-PlexSession -Reason 'Use a better browser'`

# Troubleshooting:

In the event that your token should become invalid and you receive `401` errors, try repeating the installation steps to refresh the token.
