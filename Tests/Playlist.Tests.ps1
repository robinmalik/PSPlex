BeforeDiscovery {
	Import-Module -Name "$PSScriptRoot/../Source/PSPlex.psd1" -Force -ErrorAction Stop
}

Describe "Playlist Tests" {

	BeforeAll {
		Get-Content -Path "$PSScriptRoot/../Secrets/.env" -Force | Where { $_ -like "*=*" } | ForEach-Object {
			$LineSplit = $_ -split '='
			[System.Environment]::SetEnvironmentVariable($LineSplit[0], $LineSplit[1])
		}
	}

	It "Tests New-PlexPlaylist (creating $($env:PlaylistTitle))" {
		$Item = Find-PlexItem -ItemName $env:PlaylistItemInitialTitle -ItemType movie
		$Playlist = New-PlexPlaylist -Name $env:PlaylistTitle -Type video -ItemId $Item.ratingKey
		$Playlist.leafCount | Should -BeExactly 1
	}

	It "Tests Get-PlexPlaylist (getting $($env:PlaylistTitle))" {
		$Playlist = Get-PlexPlaylist -IncludeItems | Where-Object { $_.title -eq $env:PlaylistTitle }
		$Playlist.title | Should -BeExactly $env:PlaylistTitle
		$Playlist.title | Should -BeOfType [string]
		$Playlist.items | Should -HaveCount 1
		$Playlist.items.Count | Should -BeExactly $Playlist.leafCount
		$Playlist.playlistType | Should -BeExactly "video"
	}

	It "Tests Add-PlexPlaylistItem (adding $($env:PlaylistItemAddedTitle)" {
		$Item = Find-PlexItem -ItemName $env:PlaylistItemAddedTitle -ExactNameMatch -LibraryTitle $env:FilmLibraryTitle
		$Playlist = Get-PlexPlaylist | Where-Object { $_.title -eq $env:PlaylistTitle }
		Add-PlexPlaylistItem -PlaylistId $Playlist.ratingKey -ItemId $Item.ratingKey
		$Playlist = Get-PlexPlaylist -IncludeItems | Where-Object { $_.title -eq $env:PlaylistTitle }
		$Playlist.items | Should -HaveCount 2
	}

	It "Tests Remove-PlexPlaylist (removing $($env:PlaylistTitle))" {
		$Playlist = Get-PlexPlaylist | Where-Object { $_.title -eq $env:PlaylistTitle }
		Remove-PlexPlaylist -Id $Playlist.ratingKey
		$Playlists = Get-PlexPlaylist
		$Playlists.title | Should -Not -Contain $env:PlaylistTitle
	}

	It "Tests Copy-PlexPlaylist (to another user: $($env:PSPlexTestUsername))" {
		$User = Get-PlexUser -Username $env:PSPlexTestUsername -IncludeToken
		Copy-PlexPlaylist -Id 19023 -Username $User.username -Force
		$Playlists = Get-PlexPlaylist -AlternativeToken $User.token
		$Playlists.title | Should -Contain "Harry Potter"
	}

	It "Tests Remove-PlexPlaylist (from another user: $($env:PSPlexTestUsername))" {
		$User = Get-PlexUser -Username $env:PSPlexTestUsername -IncludeToken
		$Playlists = Get-PlexPlaylist -AlternativeToken $User.token
		$PlaylistToRemove = $Playlists | Where-Object { $_.title -eq 'Harry Potter' }
		Remove-PlexPlaylist -Id $PlaylistToRemove.ratingKey -AlternativeToken $User.Token
		$Playlists = Get-PlexPlaylist -AlternativeToken $User.token
		$Playlists.title | Should -Not -Contain "Harry Potter"
	}
}

AfterAll {
	Remove-Module -Name PSPlex -Force
}