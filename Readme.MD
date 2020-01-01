# Installing <%= $PLASTER_PARAM_ModuleName %>

Run the following to install This module. To install on a server or for all users, remove the `-Scope` parameter and run in an elevated session:

```powershell
    Import-Module <%= $PLASTER_PARAM_ModuleName %> -Force -Verbose -Scope CurrentUser

    Get-Command -Module <%= $PLASTER_PARAM_ModuleName %>
```
OR

```powershell
    import-Module C:\Users\<%= $PLASTER_PARAM_FullName %>\source\repos\<%= $PLASTER_PARAM_ModuleName %> -Verbose -force -Scope CurrentUser

    Get-Command -Module <%= $PLASTER_PARAM_ModuleName %>
```

## Module Concept


### Current functionality


## Usage scenarios


## Contributing
Want to contribute to the project? See the [contributing.md](Contributing.md) for a jump start.

### TODOs until version 1
