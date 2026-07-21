BeforeDiscovery {
	Import-Module -Name "$PSScriptRoot/../Source/PSPlex.psd1" -Force -ErrorAction Stop
}

Describe "Collection Tests" {

	BeforeAll {
		Get-Content -Path "$PSScriptRoot/../Secrets/.env" -Force | Where { $_ -like "*=*" } | ForEach-Object {
			$LineSplit = $_ -split '='
			[System.Environment]::SetEnvironmentVariable($LineSplit[0], $LineSplit[1])
		}
	}

	It "Tests Get-PlexCollection by Id" {
		$Collection = Get-PlexCollection -Id $env:CollectionId -IncludeItems
		$Collection.ratingKey | Should -Be $env:CollectionId
		$Collection.title | Should -Be $env:CollectionLibraryTitle
		$Collection.childCount | Should -BeGreaterThan 0
		$Collection.Items[0].title | Should -Be $env:CollectionItemTitle
	}

	It "Tests Get-PlexCollection by LibraryId" {
		$Collections = Get-PlexCollection -LibraryId $env:CollectionLibraryId
		$Collections | Should -BeOfType [PSCustomObject]
		$Collections.Count | Should -BeGreaterThan 0
	}

	It "Tests New-PlexSmartCollection" {
		$NewCollection = New-PlexSmartCollection -Name "PlexTesting" -LibraryID $env:CollectionLibraryId -Filter "Plays IsGreaterThan 2"
	}

	It "Tests Remove-PlexCollection" {
		$Collection = Get-PlexCollection -LibraryId $env:CollectionLibraryId | Where-Object { $_.title -eq "PlexTesting" }
		Remove-PlexCollection -Id $Collection.ratingKey
	}

}

AfterAll {
	Remove-Module -Name PSPlex -Force
}