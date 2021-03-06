@{
    RootModule = 'FastLookup.psm1'
    ModuleVersion = '1.2'
    GUID = '46949985-a9d2-412a-b9a2-53d02094fe26'
    Author = 'miles.gratz'
    CompanyName = 'milesgratz.com'
    Copyright = '(c) 2017 miles.gratz. All rights reserved.'
    Description = 'PowerShell Module designed to optimize the speed of searching an array.'
    PowerShellVersion = '3.0'
    FunctionsToExport = 'New-FastLookup',
                        'Get-FastLookup',
                        'Test-FastLookup'
    CmdletsToExport = @()
    AliasesToExport = @('FastLookup')
    PrivateData = @{
        PSData = @{
            Tags = @('Arrays','Automation','Utilities','FastLookup')
        }
    }
}