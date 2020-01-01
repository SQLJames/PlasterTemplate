#To use this template replace the name of this file to be the functionname.tests.ps1
$ModuleRoot = Split-Path -Parent $(Split-Path -Parent $MyInvocation.MyCommand.Path)
$ModuleName = "<%= $PLASTER_PARAM_ModuleName %>"
#unload the module from memory
get-module $ModuleName | Remove-Module -Force
#import module to ensure we are testing the latest code
Import-Module $(Join-Path -path $ModuleRoot -childpath $( -join ($ModuleName, ".psm1"))) -Force
InModuleScope $ModuleName {
    Describe "$ModuleName tests" -Tags 'Unit' {
        #Mock Function {return $true }
        Context 'Specific Test grouping name' {
            It "Specific Test Name 1" {
                try {
                    Function -ErrorAction Stop
                }
                catch {
                    $errorThrown = $true
                }
                $errorThrown | Should -BeTrue
            }
            It "Specific Test Name 2" {
                try {
                    Function -ErrorAction Stop
                }
                catch {
                    $errorThrown = $_.Exception.Message
                }
                $errorThrown | Should -be "Error Message"
            }
        }
    }
}