#requires -version 3
<#
.SYNOPSIS
  Lookup a value in an array faster than Where-Object

.DESCRIPTION
  Improve the speed of looking up a value in an array by creating a hashtable index.
  Good for looking up results in very large arrays or CSV files (e.g Import-Csv)

.NOTES
  Version:  1.0
  Author:   Miles Gratz
  Creation Date:  April 10, 2017
  Purpose/Change: Initial script development
  
.EXAMPLE
   
  $array = 1..10000000
  $hashtable = New-FastLookup $array

  Measure-Command { $array | Where-Object { $_ -eq 199999 } }

  Days              : 0
  Hours             : 0
  Minutes           : 0
  Seconds           : 9
  Milliseconds      : 714

  Measure-Command { Get-FastLookup -Value 199999 -Array $array -Table $hashtable }

  Days              : 0
  Hours             : 0
  Minutes           : 0
  Seconds           : 0
  Milliseconds      : 65

  [NOTE] Performance test on Windows 10 x64 (i5-6200U, 8GB RAM, SSD)
#>

$Functions  = @( Get-ChildItem -Path $PSScriptRoot\*.ps1 -ErrorAction SilentlyContinue )

foreach ($Function in $Functions)
{ 
    Try
    {
        . $Function.FullName
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($Function.FullName): $_"
    }
}

Export-ModuleMember -Alias 'FastLookup'
Export-ModuleMember -Function $Functions.BaseName