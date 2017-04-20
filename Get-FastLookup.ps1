function Get-FastLookup { 
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

    .PARAMETER Array
        A mandatory parameter specifying the array used to create a 'FastLookup' (hashtable index)

    .PARAMETER Table
        A mandatory parameter specifying the 'FastLookup' created by New-FastLookup

    .PARAMETER Value
        A mandatory parameter specifying the search criteria (e.g. "Server458")

    .OUTPUTS
        The object(s) in the array that match the search
    
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

    param(
        [Parameter(Mandatory=$true)]
        $Value,
        [Parameter(Mandatory=$true)]
        [Array]$Array,
        [Parameter(Mandatory=$true)]
        [Hashtable]$Table
    )

    Try
    {
        # Lookup Value in hashtable 
        $Index = $Table[$Value]
        
        # Find quantity of Index values
        $IndexQty = ($Index -split ",").Count
        
        # Find objects in Array based on Index
        #  (if multiple, split into array)
        If ($IndexQty -eq 1){ $Array[$Index] }
        If ($IndexQty -ge 2){ $Array[$Index -split ","] }

    }
    Catch
    {
        $null
    }
}