# About

This project started out as a script to copy a playlist from my account as a Plex Server owner to another user's account (on the same server). Slowly it got broken up into separate functions and became a simple PowerShell module.

# Getting Started:

1. Install the module from the PowerShell Gallery: `Install-Module -Name PSPlex`.
2. Run: `Get-PlexAuthenticationToken`. You will be prompted to enter your Plex account name and password.
3. Run: `Save-PlexConfiguration` and provide your Plex server name, the Plex hostname (or IP address), protocol and port.
    * Example 1: `Save-PlexConfiguration -PlexServer myserver -PlexServerHostname namaste.yourdomain.com -Protocol https -Port 32400`
    * Example 2: `Save-PlexConfiguration -PlexServer myserver -PlexServerHostname 86.123.105.18 -Protocol https -Port 32400`

# Notes:

1. The Plex API has a little inconsistency with the naming of unique indentifiers for certain objects. For example, users have `id` properties, whereas libraries have `key` properties. Other objects have `ratingKey`. This makes passing identifiers sometimes odd/confusing. Please raise an issue if you get stuck.

2. Some functions return data fairly 'raw' - that is, without any helpful formatting to display the most commonly used fields (etc). Some functions however apply formatting rules in `PSPlex.Format.ps1xml`. This will be expanded later.

# Simple Examples:

**Get a list of users invited to your server:**

`Get-PlexUser`

**Get a list of libraries and select the title, type and key (Id):**

`Get-PlexLibrary | Select title,type,key`

**Get collections from library '3' show only the title and ratingKey (Id):**

`Get-PlexCollection -LibraryId 3 | Select title,ratingKey`

**Get playlists:**

`Get-PlexPlaylist`

**Remove a playlist for your account:**

`Remove-PlexPlaylist -Id 12345`

# More complex examples:

**Get a user and the libraries you've shared with them:**

`Get-PlexShare -Username 'yourfriend@theiremail.com' | Select username,@{Name='Shared';Expression={$_.Section | Where-Object { $_.Shared -eq 1} | Select -Expand Title }}`

**Get a user and their access token (for use in further automation, see the next few examples):**

`$User = Get-PlexUser -Username 'yourfriend@theiremail.com -IncludeToken`<br>
`$User.Token`

  * **Get playlists for a different account:**

    * `Get-PlexPlaylist -AlternativeToken $User.Token`

  * **Remove a playlist for a different account:**

    * `Remove-PlexPlaylist -ID 54321 -AlternativeToken $User.Token`

**Copy a playlist from your account to another account (e.g. a friend you have shared content with):**

`Copy-PlexPlaylist -PlaylistName 'Family' -Username 'yourfriend@theiremail.com' -verbose`

**Copy *all* playlists from your account to another account:**

`Get-PlexPlaylist | Foreach-Object { Copy-PlexPlaylist -PlaylistName $_.title -Username 'yourfriend@theiremail.com' }`

**Copy a single playlist to *all* users:**

`$Users = Get-PlexUser`<br>
`$Users | Foreach-Object { Copy-PlexPlaylist -PlaylistName 'Family' -Username $_.username }`

**Stop sessions where Safari is being used:**

`Get-PlexSession | Where-Object { $_.Player.platform -eq 'Safari' } | Stop-PlexSession -Reason 'Use a better browser'`

# Troubleshooting:

> In the event that your token should become invalid and you receive `401` errors, try repeating the installation steps to refresh the token.

> Should you need to delete it (e.g. to regenerate), the configuration file is stored at `$env:appdata\PSPlex\PSPlexConfig.json` on Windows, and `$HOME/.PSPlex/$FileName` on MacOS/Linux.
