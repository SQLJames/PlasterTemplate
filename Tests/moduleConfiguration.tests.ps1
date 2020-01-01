#
# This is a PowerShell Unit Test file.
# You need a unit test framework such as Pester to run PowerShell Unit tests.
# You can download Pester from https://go.microsoft.com/fwlink/?LinkID=534084
#
Import-Module PSScriptAnalyzer
$ModuleRoot = Split-Path -Parent $(Split-Path -Parent $MyInvocation.MyCommand.Path)
$module = "<%= $PLASTER_PARAM_ModuleName %>"
$ModuleFunctions = @(Get-ChildItem -Path $ModuleRoot\private\*.ps1, $ModuleRoot\Public\*.ps1 -recurse -Verbose )
$allPs1 = $(Get-ChildItem -Path $ModuleRoot\*.ps1  -recurse -Verbose )
$PublicFunctions = @((get-childitem $ModuleRoot\Public\).BaseName)
$PrivateFunctions = @((get-childitem $ModuleRoot\Private\).BaseName)
$functionsList = $PrivateFunctions + $PublicFunctions
#unload the module from memory
get-module $module | Remove-Module -Force
#import module to ensure we are testing the latest code
Import-Module $(Join-Path -path $ModuleRoot -childpath $( -join ($module, ".psm1"))) -Force

$AvailableImportedFunctions = @((Get-Command -Module $module).Name)

Describe "$module Module Tests" -Tags 'Unit' {
    Context 'Confirm Private Public Functions' {
        It "Count of Public Functions Should Match Public Folder" {
            $($AvailableImportedFunctions).Length | Should -Be $($PublicFunctions).Length
        }
        foreach ($function in $PublicFunctions) {
            It "$function Name should match Public Function Files" {
                $AvailableImportedFunctions | should contain $function
            }
        }
    }
    Context 'Module Setup' {
        It "has the root module $module.psm1" {
            "$ModuleRoot\$module.psm1" | Should -Exist
        }

        It "has the a manifest file of $module.psd1" {
            "$ModuleRoot\$module.psd1" | Should -Exist
            "$ModuleRoot\$module.psd1" | Should -FileContentMatch "$module.psm1"
        }
        It "$module is valid PowerShell code" {
            $psFile = Get-Content -Path "$ModuleRoot\$module.psm1" -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
            $errors.Count | Should -Be 0
        }
    }
    Context 'Checking for Tests on private functions' {
            foreach ($function in $PrivateFunctions) {
                    It "$($function).Tests.ps1 should exist" {
                        "$ModuleRoot\Tests\$($function).Tests.ps1" | Should -Exist
                    }
            }
        }
    Context 'Checking for Tests on Public functions' {
            foreach ($function in $PublicFunctions) {
                    It "$($function).Tests.ps1 should exist" {
                        "$ModuleRoot\Tests\$($function).Tests.ps1" | Should -Exist
                    }
            }
        }
    Context 'Checking the files with PSScriptAnalyzer' {
            ForEach ($Ps1 in $allPs1) {
                    It "$($Ps1.basename) Passes PSScriptAnalyzer" {
                        $SA = Invoke-ScriptAnalyzer -Path $($ps1.Fullname)
                        $SA.Count | Should -Be 0
                }
            }
        }
}
Describe "File Format Tests"  -Tags 'Unit' {
    foreach ($function in $ModuleFunctions) {
        Context "Test Function $($function.name)" {
            It "$($function.name) should exist in function List" {
                $functionsList | Should -Contain $function.basename
            }
            It "$($function.name) should have help block" {
                "$function" | Should -FileContentMatch '<#'
                "$function" | Should -FileContentMatch '#>'
            }

            It "$($function.name) should have a SYNOPSIS section in the help block" {
                "$function" | Should -FileContentMatch '.SYNOPSIS'
            }

            It "$($function.name) should have a DESCRIPTION section in the help block" {
                "$function" | Should -FileContentMatch '.DESCRIPTION'
            }

            It "$($function.name) should have a EXAMPLE section in the help block" {
                "$function" | Should -FileContentMatch '.EXAMPLE'
            }

            It "$($function.name) should be an advanced function" {
                "$function" | Should -FileContentMatch 'function'
                "$function" | Should -FileContentMatch 'cmdletbinding'
                "$function" | Should -FileContentMatch 'param'
            }
            It "$($function.name) should have one function" {
                $CountofFunctions = (Get-Content -Path "$function" `
                        -ErrorAction Stop | select-string -pattern "function").length
                $CountofFunctions | Should -Be 1
            }

            It "$($function.name) should contain Write-Verbose blocks" {
                "$function" | Should -FileContentMatch 'Write-Verbose'
            }

            It "$($function.name) is valid PowerShell code" {
                $psFile = Get-Content -Path "$function" `
                    -ErrorAction Stop
                $errors = $null
                $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
                $errors.Count | Should -Be 0
            }
        }
    }
}
Describe "Every test has a tag" -Tags 'Unit' {
    Get-ChildItem -Filter *.tests.ps1 -Path $ModuleRoot\Tests | ForEach-Object {
        $ast = [Management.Automation.Language.Parser]::ParseInput($(Get-Content $_.FullName -Raw), [ref]$null, [ref]$null)
        $hasDescribe = $ast.FindAll( {
                param($node)
                $node -is [System.Management.Automation.Language.CommandAst] -and
                $node.CommandElements[0].Value -eq "Describe"
            }, $true)
        foreach ($describe in $hasDescribe) {
            It "Tags exists on $($describe.CommandElements.value)" {
                $describe.CommandElements.ParameterName  | Should Be 'Tags'
            }
        }
    }
}
Describe "Describe tags are unique" -Tags 'Unit', 'Acceptance' {
    $tags = @()
    $acceptableTags = @('Integration', 'Unit', 'Acceptance')
    Get-ChildItem -Filter *.tests.ps1 -Path $ModuleRoot\Tests | Get-Content -Raw | ForEach-Object {
        $ast = [Management.Automation.Language.Parser]::ParseInput($_, [ref]$null, [ref]$null)
        $ast.FindAll( {
                param($node)
                $node -is [System.Management.Automation.Language.CommandAst] -and
                $node.CommandElements[0].Value -eq "Describe" -and
                $node.CommandElements[2] -is [System.Management.Automation.Language.CommandParameterAst] -and
                $node.CommandElements[2].ParameterName -eq "Tags"
            }, $true) | ForEach-Object {
            If ($_.CommandElements[3].extent.text -match ',') {
                foreach ($mTag in $($_.CommandElements[3].extent.text).Split(",")) {
                    $tags += $mtag
                }
            }
            Else {
                $tags += $_.CommandElements[3].extent.text
            }
        }
    }
    foreach ($tag in $tags) {
        It "$tag is in Acceptable Tags" {
            $acceptableTags | Should contain $tag.Replace("`'", "").trim()
        }
    }
}


Describe "Code Coverage" -Tags 'Unit' {
    Context 'Code Coverage for Public Functions' {
        foreach ($function in $PublicFunctions) {
            It "$function Should have code coverage over 80%" {
                $CodeCoverageResults = Invoke-Pester "$ModuleRoot\Tests\$($function).tests.ps1" -CodeCoverage "$ModuleRoot\Public\$($function).ps1" -passthru -show None
                $codeCoveragePercentage = [MATH]::Round(($CodeCoverageResults.CodeCoverage.NumberOfCommandsExecuted/$CodeCoverageResults.CodeCoverage.NumberOfCommandsAnalyzed)*100,2)
                $codeCoveragePercentage | should -BeGreaterThan 80
            }
        }
    }
    Context 'Code Coverage for Private Functions' {
        foreach ($function in $PrivateFunctions) {
            It "$function Should have code coverage over 80%" {
                $CodeCoverageResults = Invoke-Pester "$ModuleRoot\Tests\$($function).tests.ps1" -CodeCoverage "$ModuleRoot\Private\$($function).ps1" -passthru -show None
                $codeCoveragePercentage = [MATH]::Round(($CodeCoverageResults.CodeCoverage.NumberOfCommandsExecuted/$CodeCoverageResults.CodeCoverage.NumberOfCommandsAnalyzed)*100,2)
                $codeCoveragePercentage | should -BeGreaterThan 80
            }
        }
    }
}