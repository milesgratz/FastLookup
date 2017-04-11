function Get-FastLookup { 
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

    .PARAMETER Array
        A mandatory parameter specifying the array used to create a 'FastLookup' (hashtable index)

    .PARAMETER Table
        A mandatory parameter specifying the 'FastLookup' created by New-FastLookup

    .PARAMETER Value
        A mandatory parameter specifying the search criteria (e.g. "Server458")

    .OUTPUTS
        The object(s) in the array that match the search
    
    .EXAMPLE
        
        PS> $array = 1..10000000
        PS> $hashtable = New-FastLookup $array

        PS> Measure-Command { 
		    $array | Where-Object { $_ -eq 199999 } 
	    }

            Days              : 0
            Hours             : 0
            Minutes           : 0
            Seconds           : 9
            Milliseconds      : 306

        PS> Measure-Command { 
		    Get-FastLookup -Value 199999 -Array $array -Table $hashtable 
	    }

            Days              : 0
            Hours             : 0
            Minutes           : 0
            Seconds           : 0
            Milliseconds      : 65

        [NOTE] Performance test on Windows 10 x64 (i5-6200U, 8GB RAM, SSD)

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