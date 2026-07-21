BeforeDiscovery {
	Import-Module -Name "$PSScriptRoot/../Source/PSPlex.psd1" -Force -ErrorAction Stop
}

Describe "User Tests" {

	BeforeAll {
		Get-Content -Path "$PSScriptRoot/../Secrets/.env" -Force | Where-Object { $_ -like "*=*" } | ForEach-Object {
			$LineSplit = $_ -split '=', 2
			[System.Environment]::SetEnvironmentVariable($LineSplit[0].Trim(), $LineSplit[1].Trim())
		}
	}

	It "Tests Get-PlexUser" {
		$Users = Get-PlexUser
		$Users[0].title | Should -BeOfType [string]
		$Users[0].title | Should -BeExactly $Users[0].username
	}

	It "Tests Get-PlexUser with Token (user $($env:PSPlexTestUsername))" {
		$User = Get-PlexUser -Username $env:PSPlexTestUsername -IncludeToken
		$User.Token | Should -Match "^[a-z0-9_]+$"
	}
}

AfterAll {
	Remove-Module -Name PSPlex -Force
}