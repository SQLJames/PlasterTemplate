<#
File used to run all tests
#>
#$module = 'Implementation'
#$ModuleRoot = Split-Path -Parent $(Split-Path -Parent $MyInvocation.MyCommand.Path)
$testLocation = [IO.Path]::Combine($(Split-Path -path $($myinvocation.mycommand.path)).ToString(), "Tests")
#$PublicFunctions = @((get-childitem $ModuleRoot\$module\Public\).BaseName)
#$PrivateFunctions = @((get-childitem $ModuleRoot\$module\Private\).BaseName)
If (!(Get-module Pester)) {
    Import-Module Pester
}
Invoke-Pester $testLocation -tag 'Unit' -OutputFormat NUnitXml -OutputFile "$PSScriptRoot\NUnitXml.xml"