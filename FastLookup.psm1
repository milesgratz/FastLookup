#requires -version 3
<#
.SYNOPSIS
    Designed to optimize the speed of searching an array.

.DESCRIPTION
    Improve the speed of looking up a value in an array by creating a hashtable index.
    Good for looping through very large arrays or CSV files

.NOTES
    Version:  1.2
    Author:   Miles Gratz
    Creation Date:  April 20, 2017
    Purpose/Change: Improve examples
  
.EXAMPLE

    PS>           
    
    $array = 1..1000000
    $hashtable = New-FastLookup -Array $array
    Get-FastLookup -Value 2017 -Array $array -Table $hashtable

.EXAMPLE

    PS>

    # Search for thousand random numbers in an array of one million

    $array  = 1..1000000
    $search = 1..1000 | ForEach-Object { 
        Get-Random -Maximum $array.Count 
    } 

    ---------------------------------------------------------------
    
    Where-Object Performance Test

    Measure-Command { 
        $array | Where-Object { $_ -in $search } 
    }

    Minutes           : 2
    Seconds           : 39
    Milliseconds      : 658

    ---------------------------------------------------------------

    ForEach Performance Test

    Measure-Command { 
        foreach ($item in $array){ if ($item -in $search){ $item } } 
    }

    Minutes           : 1
    Seconds           : 27
    Milliseconds      : 460

    ---------------------------------------------------------------

    FastLookup Performance Test

    Measure-Command {
        $hashtable = New-FastLookup -Array $array        
        foreach ($item in $search){ 
            Get-FastLookup -Value $item -Array $array -Table $hashtable 
        }
    }

    Minutes           : 0
    Seconds           : 49
    Milliseconds      : 933

    ---------------------------------------------------------------

    [NOTE] Performance test on Windows 10 x64 (i5-6200U/8GB/SSD)
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