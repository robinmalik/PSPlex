BeforeDiscovery {
	Import-Module -Name "$PSScriptRoot/../Source/PSPlex.psd1" -Force -ErrorAction Stop
}

Describe "Item Tests" {

	BeforeAll {
		Get-Content -Path "$PSScriptRoot/../Secrets/.env" -Force | Where-Object { $_ -like "*=*" } | ForEach-Object {
			$LineSplit = $_ -split '=', 2
			[System.Environment]::SetEnvironmentVariable($LineSplit[0].Trim(), $LineSplit[1].Trim())
		}
	}

	It "Tests Find-PlexItem by Movie Type" {
		$Item = Find-PlexItem -ItemName $env:ItemMovieTitleSearch -ItemType movie
		$Item.title | Should -BeExactly $env:ItemMovieTitle
		$Item.type | Should -BeExactly "movie"
		$Item.ratingKey | Should -Be $env:ItemMovieId
		$Item.key | Should -Match "/library/metadata/$($Item.ratingKey)"
		$Item.guid | Should -Match "^plex:\/\/movie\/[a-z0-9]+$"
		$item.librarySectionID.GetType().Name | Should -Match "Int32|Int64"
		$Item.librarySectionID | Should -BeExactly $env:ItemMovieLibraryId
		$Item.librarySectionKey | Should -Match "/library/sections/$($Item.librarySectionID)"
	}

	It "Tests Find-PlexItem by Library Title" {
		$Item = Find-PlexItem -ItemName $env:ItemEpisodeTitleSearch -LibraryTitle $env:TVLibraryTitle
		$Item.title | Should -BeExactly $env:ItemEpisodeTitleSearch
		$Item.type | Should -BeExactly "episode"
		$Item.ratingKey | Should -Be $env:ItemEpisodeId
		$Item.key | Should -Match "/library/metadata/$($Item.ratingKey)"
		$Item.guid | Should -Match "^plex:\/\/episode\/[a-z0-9]+$"
		$item.librarySectionID.GetType().Name | Should -Match "Int32|Int64"
		$Item.librarySectionID | Should -BeExactly $env:ItemEpisodeLibraryId
		$Item.librarySectionKey | Should -Match "/library/sections/$($Item.librarySectionID)"
	}

	It "Tests Get-PlexItem by Id" {
		$Item = Get-PlexItem -Id $env:ItemMovieId
		$Item.ratingKey | Should -Be $env:ItemMovieId
		$Item._guid | Should -Match "^plex:\/\/movie\/[a-z0-9]+$"
		$Item.type | Should -BeExactly "movie"
		$Item.title | Should -BeExactly $env:ItemMovieTitle
		$Item.librarySectionID.GetType().Name | Should -Match "Int32|Int64"
		$Item.librarySectionKey | Should -Match "/library/sections/$($Item.librarySectionID)"
	}
}

AfterAll {
	Remove-Module -Name PSPlex -Force
}