# Changelog

## [1.0.9] - 2022-11-23

* 🔨 [Changed] MAJOR: Functions now construct the URi for calls using a private function.
* ✨ [New] `Get-PlexItem` can now get album track data. Example: `Get-PlexItem -Id 123 -IncludeTracks`
* ✨ [New] `Set-PlexItemRating` for rating items from 1-5. Whilst the Plex API will accept 0, the UI won't display that accurately so I've prevented it.
* 📚 [Added] Completed syntax blocks for _all_ functions.
* 🎨 [Added] Added region blocking to improve readability of code.
* 🐛 [Fixed] `Get-PlexSession` now handles returned JSON with duplicate keys. The handling of this should become a function in later releases.

## [1.0.8] - 2022-11-18

* 📚 [Added] Updated documentation to be more consistent. Added syntax blocks for the last two released functions.

## [1.0.7] - 2022-11-17

* ✨ [New] `Add-PlexLabel` and `Remove-PlexLabel`, for adding labels to Plex items (i.e. to control sharing restrictions and provide additional filtering abilities). Testing on albums, shows and movies.
* 🐛 [Fixed] `Get-PlexItem` now handles both **valid** JSON returned from the Plex API for this endpoint. It had previously assumed all JSON was faulty.

## [1.0.6] - 2022-10-28

* 🐛 [Fixed] Use `""` not `$Null` for previous "fix".

## [1.0.5] - 2022-10-27

* 🐛 [Fixed] Make `Get-PlexUser` populate user tokens for home users.

## [1.0.4] - 2022-09-02

* 🔨 [Changed] Make `Save-PlexConfiguration` import new config immediately after saving it to disk.

## [1.0.3] - 2022-08-12

* 🔨 [Changed] MAJOR: Updated queries to request JSON from Plex servers rather than XML.
* 🔨 [Changed] MAJOR: `Get-PlexItem` remaps `guid` and `rating` with `_` prefixes due to the presence of additional uppercase Guid and Rating keys.
* 🔨 [Changed] Reworked `Import-PlexConfiguration` to use script scoped variables, meaning it isn't called every time a cmdlet is required.
* ✨ [New] `Set-PlexWebHook` lets you configure the URL to which your Plex server will send webhooks.
* 🐛 [Fixed] Updated `Add-PlexItemToPlaylist` to use updated variable names for Plex config data.

## [1.0.2] - 2022-02-20

* 🔨 [Changed] `Get-PlexPlaylist`: Removed one level of nesting for items. Previously you'd have to do this: `$Playlist.Items.Metadata`. Now: `$Playlist.Items`
* 🔨 [Changed] `Copy-PlexPlaylist`: Call `Remove-PlexPlaylist` internally rather than additional equivalent code.

## [1.0.1] - 2022-02-20

* 🔨 [Added] Restored `-Force` parameter to `Copy-PlexPlaylist` which will overwrite (delete and recreate) a destination playlist.

## [1.0.0] - 2022-02-18

* 🎉 Initial release.