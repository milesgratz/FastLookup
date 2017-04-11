function New-FastLookup {
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
        A mandatory parameter specifying input array used to create 'FastLookup'

    .PARAMETER Header
        An optional parameter specifying the header in the input array used to create 'FastLookup'
 
    .OUTPUTS
        A hashtable, listing the values in the array and their corresponding index
    
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
        [array]$Array,
        $Header
    )

    # Identify headers in input array
    $Headers = $Array | Get-Member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name'
    
    # Define empty hashtable and index
    $HashTable = @{}
    $Index = 0
   
    #1: Header specified
    #2: Header exists in array
    If (($Header -ne $null) -and ($Header -in $Headers))
    {
        # Redefine array with only data from specified Header
        $Array = $Array.$Header
    }
    
    #1: Header is specified
    #2: Header does NOT exist in array
    ElseIf (($Header -ne $null) -and ($Header -notin $Headers))
    {
        # Exit function with error
        Write-Error "Specified header ($Header) does not exist in input array."
        Break
    }

    #1: Header is NOT specified
    #2: Array contains multiple Headers
    ElseIf (($Header -eq $null) -and ($Headers.Count -gt 1))
    {
        # Exit function with error
        Write-Error "Input array requires the -Header parameter (multiple columns detected)."
        Break
    }

    # Loop through array
    foreach ($Item in $Array)
    {
        # Add index of Item to hashtable
        #     Name                Value
        #     ----                -----
        #     Server1             953
        #     Server2             1157
        Try
        {
            $HashTable.Add($Item,$Index)
        }

        # Duplicate key detected, add to existing value
        #     Name                Value                                                                                                                                                                         
        #     ----                -----
        #     Server1             953
        #     Server2             1157,3325                                                                                                                                                                                    
        Catch
        {       
            $HashTable[$Item] = ($HashTable[$Item],$Index -join ",")         
        }
        
        # Increment loop
        $Index++
    }
    
    # Output results
    $HashTable
}
