# Changelog

## [1.0.20] - 2026-07-20

- ⚠️ [Breaking] `AddPlexItemToPlaylist` is renamed to `Add-PlexPlaylistItem`.
- ✨ [New] Committed some basic Pester tests (relies on a local `./Secrets/.env`)
- 🔨 [Changed] Centralised all HTTP calls through a new private `Invoke-PlexRequest` gateway function, folding in the old `Get-PlexAPIUri` URI builder.
- 🔨 [Changed] The Plex token is now sent as the `X-Plex-Token` header rather than a query-string parameter, keeping it out of URLs and logs.
- 🔨 [Changed] Removed implicit `$PSDefaultParameterValues` from `Import-PlexConfiguration`; all request defaults are now explicit inside `Invoke-PlexRequest`.
- 🐛 [Fixed] Improved UTF-8 decoding on Windows PowerShell 5.1 (e.g. emoji in playlist titles).
- 🔨 [Changed] Better, token-redacted error messages including a 401 re-configuration hint.

## [1.0.19] - 2025-09-13

- 🐛 [Fixed] Fixed hardcoded library reference in [Copy-PlexPlaylist](https://github.com/robinmalik/PSPlex/issues/19).

## [1.0.18] - 2024-12-24

- 🐛 [Fixed] Improved the handling of detected Plex servers (online, custom domain name, remote access disabled, etc).

## [1.0.17] - 2024-05-04

- 🐛 [Fixed] Attempt to cater to servers that do not have remote access enabled (i.e. private/local LAN). Users will need to run Set-PlexConfiguration again and reopen PowerShell.

## [1.0.16] - 2024-04-11

- ✨ [New] `New-PlexSmartCollection` for creating new smart collections in Plex libraries (thanks to [solid03](https://github.com/solid03)).

## [1.0.15] - 2024-03-22

- ✨ [New] `Remove-PlexCollection` for removing collections from Plex libraries (thanks to [solid03](https://github.com/solid03)).

## [1.0.14] - 2023-10-15

- ✨ [New] `Set-PlexDefaultServer` for setting the default server to use for all future calls.
  - Context: `Set-PlexConfiguration` is called, a default is set as part of this. This function allows you to change it.
- ✨ [New] `Get-PlexPlaylist` and `Get-PlexLibrary` now support `-Name`. The Plex API doesn't support this natively, so it's client side filtered.
- ✨ [New] `Get-PlexWatchHistory` for returning the watch history for either yourself or another user (with `-Username`).

## [1.0.13] - 2023-09-02

- 🔨 [Changed] BREAKING CHANGES: Removed `Get-PlexAuthenticationToken` and `Save-PlexConfiguration`. We now have a single function: `Set-PlexConfiguration`.
- 🔨 [Changed] BREAKING CHANGES: Reworked credential file structure, including removal of token encryption for Windows.
- ✨ [New] `Set-PlexItemEdition` for setting the 'edition' of movie items.

## [1.0.12] - 2023-01-13

- ✨ [New] `New-PlexPlaylist` for creating new (video) playlists.
- 🐛 [Fixed] Ensure `Get-PlexPlaylist -IncludeItems` doesn't throw an error for 'Smart' playlists.
- 🔨 [Changed] `Add-PlexItemToPlaylist` handles adding multiple plex items.

## [1.0.11] - 2022-12-28

- 🐛 [Fixed] Finished fixing (relevant) PSScriptAnalyzer issues.
- 🔨 [Changed] Finished migration of functions to internal Uri constructor.

## [1.0.10] - 2022-12-25

- 🐛 [Fixed] Fixed some PSScriptAnalyzer issues (to complete later).

## [1.0.9] - 2022-12-18

- 🔨 [Changed] MAJOR: Most functions now construct the URi for calls using a private function.
- ✨ [New] `Get-PlexItem` can now get album track data. Example: `Get-PlexItem -Id 123 -IncludeTracks`
- ✨ [New] `Set-PlexItemRating` for rating items from 1-5. Whilst the Plex API will accept 0, the UI won't display that accurately so I've prevented it.
- 📚 [Added] Completed syntax blocks for _all_ functions.
- 🎨 [Added] Added region blocking to improve readability of code.
- 🐛 [Fixed] `Get-PlexSession` now handles returned JSON with duplicate keys. The handling of this should become a function in later releases.

## [1.0.8] - 2022-11-18

- 📚 [Added] Updated documentation to be more consistent. Added syntax blocks for the last two released functions.

## [1.0.7] - 2022-11-17

- ✨ [New] `Add-PlexLabel` and `Remove-PlexLabel`, for adding labels to Plex items (i.e. to control sharing restrictions and provide additional filtering abilities). Testing on albums, shows and movies.
- 🐛 [Fixed] `Get-PlexItem` now handles both **valid** JSON returned from the Plex API for this endpoint. It had previously assumed all JSON was faulty.

## [1.0.6] - 2022-10-28

- 🐛 [Fixed] Use `""` not `$Null` for previous "fix".

## [1.0.5] - 2022-10-27

- 🐛 [Fixed] Make `Get-PlexUser` populate user tokens for home users.

## [1.0.4] - 2022-09-02

- 🔨 [Changed] Make `Save-PlexConfiguration` import new config immediately after saving it to disk.

## [1.0.3] - 2022-08-12

- 🔨 [Changed] MAJOR: Updated queries to request JSON from Plex servers rather than XML.
- 🔨 [Changed] MAJOR: `Get-PlexItem` remaps `guid` and `rating` with `_` prefixes due to the presence of additional uppercase Guid and Rating keys.
- 🔨 [Changed] Reworked `Import-PlexConfiguration` to use script scoped variables, meaning it isn't called every time a cmdlet is required.
- ✨ [New] `Set-PlexWebHook` lets you configure the URL to which your Plex server will send webhooks.
- 🐛 [Fixed] Updated `Add-PlexItemToPlaylist` to use updated variable names for Plex config data.

## [1.0.2] - 2022-02-20

- 🔨 [Changed] `Get-PlexPlaylist`: Removed one level of nesting for items. Previously you'd have to do this: `$Playlist.Items.Metadata`. Now: `$Playlist.Items`
- 🔨 [Changed] `Copy-PlexPlaylist`: Call `Remove-PlexPlaylist` internally rather than additional equivalent code.

## [1.0.1] - 2022-02-20

- 🔨 [Added] Restored `-Force` parameter to `Copy-PlexPlaylist` which will overwrite (delete and recreate) a destination playlist.

## [1.0.0] - 2022-02-18

- 🎉 Initial release.
