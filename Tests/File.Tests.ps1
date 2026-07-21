BeforeDiscovery {
	Write-Host "❗ BeforeDiscovery ------------------------------------"
	$ModuleName = $PSScriptRoot | Split-Path -Parent | Split-Path -Leaf
	Import-Module -Name "$PSScriptRoot/../Source/$ModuleName.psd1" -Force -ErrorAction Stop
	$Module = Get-Module $ModuleName
	$CommandList = @(
		$Module.ExportedFunctions.Keys
		$Module.ExportedCmdlets.Keys
	)
	$FunctionFiles = Get-ChildItem -Path "$PSScriptRoot/../Source/" -Recurse -Filter *.ps1
}

Describe "File Formatting Tests" {

	BeforeAll {
	}

	It "Check for BOM encoding: <_.Name>" -ForEach $FunctionFiles {
		$Bytes = [System.IO.File]::ReadAllBytes($_.FullName)
		$HasBom = $Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF
		$HasBom | Should -BeFalse
	}

	It "Checks file extension is lowercase: <_.Name>" -ForEach $FunctionFiles {
		$Extension = $_.Extension
		$Extension | Should -BeExactly $Extension.ToLower()
	}

	It "Tests Code is Tab Indented: <_.Name>" -ForEach $FunctionFiles {
		$Lines = Get-Content -Path $_.FullName
		foreach($Line in $Lines)
		{
			if($Line -match "^\s+")
			{
				$Line | Should -Not -Match "^ +"
			}
		}
	}
}

Describe "Function Consistency Tests" {

	Context "Documentation Checks: <_> " -ForEach $CommandList {

		BeforeAll {
			# Runs once for each command in the Context
			$Help = Get-Help -Name ($_ ) -ErrorAction SilentlyContinue
		}

		It "Should have thorough comment-based help" {
			$Help | Should -Not -BeNullOrEmpty
			$Help.Synopsis | Should -Not -BeNullOrEmpty
			$Help.Description | Should -Not -BeNullOrEmpty
			$Help.Examples | Should -Not -BeNullOrEmpty

		}
	}
}