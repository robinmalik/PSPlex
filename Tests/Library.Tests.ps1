BeforeDiscovery {
	Import-Module -Name "$PSScriptRoot/../Source/PSPlex.psd1" -Force -ErrorAction Stop
}

Describe "Library Tests" {

	BeforeAll {
		Get-Content -Path "$PSScriptRoot/../Secrets/.env" -Force | Where-Object { $_ -like "*=*" } | ForEach-Object {
			$LineSplit = $_ -split '=', 2
			[System.Environment]::SetEnvironmentVariable($LineSplit[0].Trim(), $LineSplit[1].Trim())
		}
	}

	It "Tests Get-PlexLibrary" {
		$Libraries = Get-PlexLibrary
		$Libraries[0].title | Should -BeOfType [string]
		$Libraries[0].type | Should -BeOfType [string]
		$Libraries.Count | Should -BeGreaterThan 1
	}

	It "Tests Get-PlexLibrary by Id" {
		$Library = Get-PlexLibrary -Id $env:ItemMovieLibraryId
		$Library.title | Should -BeExactly $env:MovieLibraryTitle
		$Library.type | Should -BeExactly "movie"
		$Library.key | Should -BeExactly $env:ItemMovieLibraryId
	}
}