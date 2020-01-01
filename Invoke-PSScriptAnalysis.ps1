$Ps1s = $(Get-ChildItem -Path $PSScriptRoot\*.ps1  -recurse -Verbose )
Import-Module PSScriptAnalyzer
ForEach ($Ps1 in $ps1s){
    Invoke-ScriptAnalyzer -Path $($ps1.Fullname)
}