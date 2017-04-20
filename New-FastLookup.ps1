function New-FastLookup {
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
        A mandatory parameter specifying input array used to create 'FastLookup'

    .PARAMETER Header
        An optional parameter specifying the header in the input array used to create 'FastLookup'
 
    .OUTPUTS
        A hashtable, listing the values in the array and their corresponding index
    
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