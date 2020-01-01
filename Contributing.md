Here, we'll help you understand how to contribute to the project, and talk about fun stuff like styles and guidelines.

# Contributing

Let's sum this up saying that we'd love your help. There are several ways to contribute:

- Create new commands (PowerShell knowledge required)
- Report bugs (everyone can do it)
- Tests (Pester knowledge required)
- Documentation: functions, website, this guide, everything can be improved (everyone can)
- Code review (PowerShell knowledge required)

## Documentation

Documentation is an area that is a good starting point.
The documentation focus is around our comment-based help (CBH).
The CBH is included with every public command (and some internal), and is the content you see using `Get-Help Function-Name`. 
Reviewing the content to ensure it is clear on what the command is used for, along with working examples is a key area of discussion. 
Whether you are first starting out with PowerShell or have been using it for years, your fresh eyes can help spot inaccuracies or areas of improvement on how we document each command. 
```Powershell
function Get-Example {
    <#
    .SYNOPSIS
        A brief description of the function or script.

    .DESCRIPTION
        A longer description.

    .PARAMETER FirstParameter
        Description of each of the parameters.
        Note:
        To make it easier to keep the comments synchronized with changes to the parameters,
        the preferred location for parameter documentation comments is not here,
        but within the param block, directly above each parameter.

    .PARAMETER SecondParameter
        Description of each of the parameters.

    .INPUTS
        Description of objects that can be piped to the script.

    .OUTPUTS
        Description of objects that are output by the script.

    .EXAMPLE
        Example of how to run the script.

    .LINK
        Links to further documentation.

    .NOTES
        Detail on what the script does, if this is needed.

    #>
```
More examples can be found by looking into Comment based help for powershell online or in the [Microsoft Documentation](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-6).

## Fix Bugs
Submit Pull Requests targeting ideally just one ps1 file, with the name of the function being fixed as a title. Everyone will chime in reviewing the code and either approve the PR or request changes. The more targeted and focused the PR, the easier to merge, the fastest to go into the next release. Keep them as simple as possible to speed up the process. Helpful guide below:

- Fork the project, clone your fork, and configure the remotes
    - If you cloned the project a while ago, get teh latest changes
- Create a new topic branch (off the main project branch) to contain your feature, change, or fix.
    ```git checkout -b <topic-branch-name>```
- Commit your changes in logical chunks. For any Git project, some good rules for commit messages are
    - the first line is commit summary, 50 characters or less,
    - followed by an empty line
    - followed by an explanation of the commit, wrapped to 72 characters.
- The first line of a commit message becomes the title of a pull request on GitHub, like the subject line of an email. Including the key info in the first line will help us respond faster to your pull.
- Push your topic branch up to your fork
    ```git push origin <topic-branch-name>```



## Parameters and Variables

As a reference: 
- when we refer to [parameters](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_parameters) these at the command level for accepting input; used when calling a given command like `New-ClientIISSite -WebsiteDomain ggastrocloud.com` (`WebsiteDomain` is the parameter). 
- A [variable](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_variables) is used within a given command to store values or objects that are used in the given command's code.

We chose to follow the standards below when creating parameters and variables for a function:

1) Any variable used in the parameter block must have first letter of each word capitalized. (e.g. `$SqlInstance`)
1) Any variable used in the parameter block **is required** to be singular.
1) Any variable not part of the parameter block, that is multiple words, will follow the camelCase format. (e.g. `$dbLogin`)
1) Refrain from using single character variable names (e.g. `$i` or `$x`). Try to make them "readable" in the sense that if someone sees the variable name they can get a hint what it presents (e.g. `$url`, `$site`) OR  e.g. `foreach ($database in $databases)` instead of `foreach ($db in $dbs)`
1) When you are working with "objects", say with databases, what variable name you use should be based on what operation you are doing. As an example: in situations where you are looping over the databases for an instance, try to use a plural variable name for the collection and then single or abbreviated name in the loop for each object of that collection. e.g. `foreach ($database in $databases)`.



## Formatting and indentation

Consistency is key; throughout the project and accept PRs coming from anybody. 
When using VSCode, install the powershell extension. They have a keyboard shortcut to format files:
SHIFT+ALT+F


## Tests

Remember that tests are needed to make sure the code behaves properly. The ultimate goal is for any user to be able to run this modules' tests within their environment and, depending on the result, be sure everything works as expected. 

### How to write tests

To save resources and be more flexible, we split tests with tags into two main categories, `UnitTests` and `IntegrationTests`. Below is a starting list of things to consider when writing your test:

- `UnitTests` do not require an instance to be up and running, and are easily the most flexible to be ran on every user computer. - `IntegrationTests` instead require one or more active instances, and there is a bit of setup to do in order to run them.
- Every one of the `IntegrationTests` may need to create a resource (e.g. a database Or an IIS Site).
- Every resource should be named with the `testEnv_` prefix. _The test should attempt to clean up after itself leaving a pristine environment._
- Try to write tests thinking they may run in each and every user's test environment.

You'll see that every test file is named with a simple convention `Verb-Noun*.Tests.ps1`, and this is required by [Pester](https://GitHub.com/pester/Pester), which is the de-facto standard for running tests in PowerShell.

### Installing Pester (PSv5a and above)

```Powershell
If ($PSVersionTable.PSVersion.Major -eq 5) {
    if (Get-Module -ListAvailable -Name Pester) {
        Write-Output "Module exists"
        Write-Output "Attempting to update"
        Update-Module Pester -Force
    } 
    else {
        Write-Output "Module does not exist"
        Write-Output "Attempting to Install"
        Install-module Pester -Force
    }
}
```

#### Serialize Data For Mock data

```Powershell
#Location to send the Serialized Data to Disk
$ExportPath= "$env:APPDATA\PoshXmlSerializationData.xml"
#Function you want to Serialize
$data = Get-ChildItem C:\Users\
#Serialize the data to disk
$data | Export-Clixml $ExportPath
#copy the file item to the clipboard
get-content $ExportPath | clip
#Place the file into a variable in the test file 
$MockedSerializedgetChildItem =@'
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">
  <Obj RefId="0">
    <TN RefId="0">
      <T>System.IO.DirectoryInfo</T>
      <T>System.IO.FileSystemInfo</T>
      <T>System.MarshalByRefObject</T>
      <T>System.Object</T>
    ...
'@
#To Deserialize the data use the following:
$MockedItem = [System.Management.Automation.PSSerializer]::DeserializeAsList($MockedSerializedgetChildItem)
#your $mockeditem will now contain the original data Allowing you to set static variables
```

#### Tagging Unit Tests
With Pester you have the ability to tag test describe blocks `Describe -Tags ('Unit')` This allows you to run blocks of tests without needing to subdivide tests into multiple files
Unfortunately, these tags are not hardcoded - for our Module we will be using the following tags
- Acceptance
- Unit
- Integration 
This means that all describe blocks need to be tagged.

#### $TestDrive variable to output files too
TestDrive is a PowerShell PSDrive for file activity limited to the scope of a single Describe or Context block in pester.
Pester creates a PSDrive inside the user's temporary drive that is accessible via a named PSDrive TestDrive:. Pester will remove this drive after the test completes. You may use this drive to isolate the file operations of your test to a temporary store.
More information can be found on the [Pester Wiki](https://github.com/pester/Pester/wiki/TestDrive)

#### Testing code coverage with Pester
To run a code coverage test against your unit tests use the following command 
```Powershell
invoke-pester .\Tests\FunctionName.tests.ps1 -codecoverage .\Private\functionname.ps1
```

## Extensions
##### Markdown editor
Created in Markdown editor extion on visual studio code 
###### Markdown editor ShortCuts

Keybindings
The cmd key for Windows is ctrl.

Shortcuts	Functionality
cmd-k v Created in Markdown editor extion on visual studio code 	Open preview to the Side
ctrl-shift-v	Open preview
ctrl-shift-s	Sync preview / Sync source
shift-enter	Run Code Chunk
ctrl-shift-enter	Run all Code Chunks
cmd-= or cmd-shift-=	Preview zoom in
cmd-- or cmd-shift-_	Preview zoom out
cmd-0	Preview reset zoom
esc	Toggle sidebar TOC
