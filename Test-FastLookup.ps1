function Test-FastLookup {
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
 
    .OUTPUTS
        1. Creates a sample array
        2. Measures speed of searching array with Where-Object, Foreach/If, and Get-FastLookup
    
    .EXAMPLE
        
        PS> Test-FastLookup -ArraySize 100000 -SearchSize 10000

        Creating 'speedtest' array (total array size: 100000; search size: 10000)
        Example object:

        DeviceName                         : DeviceName9475
        Type                               : Security Camera
        IP                                 : 10.10.128.62
        VLAN                               : VLAN86
        Location                           : Los Angeles
        Patch Window                       : Saturday
        Warranty Service Level             : 24x7
        Warranty Days Left                 : 124
        Primary Technical Contact          : Chris
        Application Manager                : Doug
        Severity Level                     : Harry
        Technical Emergency Contact Number : P1
        Manager Emergency Contact Number   : 515-249-1602


        ---------------------------------------------------------------

        Measuring speed of Where-Object lookup:
        
        $Results = $Array | Where-Object { $_.DeviceName -in $Search }       
		
		Days         : 0
        Hours        : 0
        Minutes      : 4
        Seconds      : 18
        Milliseconds : 366
		

		---------------------------------------------------------------

        Measuring speed of Foreach/If lookup:
        
        [System.Collections.ArrayList]$Results = @()
        foreach ($Item in $Array)
        { 
            If ($Item.DeviceName -in $Search)
            { 
                [void]$Results.Add($Item)
            } 
        }	
        
        Days         : 0
        Hours        : 0
        Minutes      : 4
        Seconds      : 14
        Milliseconds : 148
		

		---------------------------------------------------------------

        Measuring speed of Get-FastLookup lookup:
        
        $Hashtable = New-FastLookup -Array $Array -Header "DeviceName"
        [System.Collections.ArrayList]$Results = @()
        foreach ($Item in $Search)
        {  
            [void]$Results.Add((Get-FastLookup -Value $Item -Array $Array -Table $Hashtable))
        }

        Days         : 0
        Hours        : 0
        Minutes      : 0
        Seconds      : 52
        Milliseconds : 773


        --------------------------------------------------------------
    
        [NOTE] Performance test on Windows 10 x64 (i5-6200U/8GB/SSD)

    #>
    param(
        # Default sample size of 100K, searching for 10K objects
        [int]$ArraySize = 100000,
        [int]$SearchSize = 10000
    )

    # Define empty ArrayList for sample array
    [System.Collections.ArrayList]$csvLines = @()

    # Create array based on quantity
    $Index = 0
    Write-Output "Creating 'speedtest' array (total array size: $ArraySize; search size: $SearchSize)"
    while ($Index -lt $ArraySize)
    {
        # Calculate percentage
        $PercentageIndex = $Percentage
        $Percentage = [math]::Round((($Index / $ArraySize)*100))

        # Announce percentage
        If ($Percentage -gt $PercentageIndex)
        {
            Write-Output "Creating 'speedtest' array ($Percentage%)"
        }
        
        # Example template
        $DeviceNumber = Get-Random -Maximum $($ArraySize*5)
        $Type = Get-Random 'Laptop','Workstation','Network Switch','Wireless Access Point','Security Camera','Server'
        $IP =  "10.10.128." + (Get-Random (1..254))
        $VLAN = "VLAN" + (Get-Random (1..100))
        $Location = Get-Random 'Chicago','New York','Los Angeles'
        $PatchWindow = Get-Random 'Sunday','Saturday'
        $WarrantyServiceLevel = Get-Random '24x7','Next Business Day','Parts Only'
        $WarrantyDaysLeft = Get-Random -Minimum -100 -Maximum 1095
        $PrimaryTech = Get-Random 'Angela','Bob','Chris'
        $SecondaryTech = Get-Random 'Doug','Eileen','Francis'
        $AppManager = Get-Random 'Grace','Harry','Isabel'
        $SeverityLevel = Get-Random 'P1','P2','P3','P4'
        $TechEmergencyNum = "515-249-" + (0..9 | Get-Random) + (0..9 | Get-Random) + (0..9 | Get-Random) + (0..9 | Get-Random)
        $MgrEmergencyNum = "515-249-" + (0..9 | Get-Random) + (0..9 | Get-Random) + (0..9 | Get-Random) + (0..9 | Get-Random)
        
        # Create custom object to add to array
        $csvLine = (('"DeviceName' + $DeviceNumber),
                    $Type,
                    $IP,
                    $VLAN,
                    $Location,
                    $PatchWindow,
                    $WarrantyServiceLevel,
                    $WarrantyDaysLeft,
                    $PrimaryTech,
                    $SecondaryTech,
                    $AppManager,
                    $SeverityLevel,
                    $TechEmergencyNum,
                    ($MgrEmergencyNum + '"')) -join '","'
        
        # Add object to array
        [void]$csvLines.Add($csvLine)
    
        # Increment loop
        $Index++
    }

    # Convert lines to CSV
    [string[]]$stringArray += '"DeviceName","Type","IP","VLAN","Location","Patch Window","Warranty Service Level","Warranty Days Left","Primary Technical Contact","Application Manager","Severity Level","Technical Emergency Contact Number","Manager Emergency Contact Number"'
    $stringArray += $csvLines
    [array]$Array = $stringArray | ConvertFrom-Csv
    
    # Create list of random server names
    $Index = 0
    [System.Collections.ArrayList]$Search = @()

    while ($Index -lt $SearchSize)
    {
        $RandomIndex = Get-Random -Minimum 0 -Maximum ($Array.Count-1)
        $Random = $Array[$RandomIndex]
        [void]$Search.Add($Random.DeviceName)
        $Index++
    }

    # Example object
    Write-Output ""
    Write-Output "Example object:"
    Write-Output $Array[0]

    # Measuring speed of Where-Object lookup
    Write-Output ""
    Write-Output ('-'*80)
    Write-Output 'Measuring speed of Where-Object lookup:'
    Write-Output ""
    Write-Output ('$Results = $Array | Where-Object { $_.DeviceName -in $Search }')
    $MeasureWhereObject = Measure-Command { 
        $Results = $Array | Where-Object { $_.DeviceName -in $Search }
    } | Select-Object Days,Hours,Minutes,Seconds,Milliseconds
    Write-Output $MeasureWhereObject
    Write-Output ""
    Write-Output "Number of results: $($Results.Count)"
    Write-Output "First result:"
    Write-Output ""
    Write-Output $Results[0]
    
     # Measuring speed of ForEach lookup
    Write-Output ""
    Write-Output ('-'*80)
    Write-Output 'Measuring speed of Foreach/If lookup:'
    Write-Output ""
    Write-Output '[System.Collections.ArrayList]$Results = @()'
    Write-Output 'foreach ($Item in $Array)'
    Write-Output '{'
    Write-Output '    If ($Item.DeviceName -in $Search)' 
    Write-Output '    {'
    Write-Output '        [void]$Results.Add($Item)'
    Write-Output '    }'
    Write-Output '}'
    $MeasureForeachIf = Measure-Command {
        [System.Collections.ArrayList]$Results = @()
        foreach ($Item in $Array)
        { 
            If ($Item.DeviceName -in $Search)
            { 
                [void]$Results.Add($Item)
            } 
        }
    } | Select-Object Days,Hours,Minutes,Seconds,Milliseconds
    Write-Output $MeasureForeachIf
    Write-Output ""
    Write-Output "Number of results: $($Results.Count)"
    Write-Output "First result:"
    Write-Output ""
    Write-Output $Results[0]
 
    # Measuring speed of Get-FastLookup
    Write-Output ""
    Write-Output ('-'*80)
    Write-Output 'Measuring speed of Get-FastLookup lookup:'
    Write-Output ""
    Write-Output '$Hashtable = New-FastLookup -Array $Array -Header "DeviceName"'
    Write-Output '[System.Collections.ArrayList]$Results = @()'
    Write-Output 'foreach ($Item in $Search)'
    Write-Output '{'
    Write-Output '    [void]$Results.Add((Get-FastLookup -Value $Item -Array $Array -Table $Hashtable))'
    Write-Output '}'
    $MeasureFastLookup = Measure-Command {
        $Hashtable = New-FastLookup -Array $Array -Header "DeviceName"
        [System.Collections.ArrayList]$Results = @()
        foreach ($Item in $Search)
        {  
            [void]$Results.Add((Get-FastLookup -Value $Item -Array $Array -Table $Hashtable))
        }
    } | Select-Object Days,Hours,Minutes,Seconds,Milliseconds
    Write-Output ""
    Write-Output $MeasureFastLookup
    Write-Output ""
    Write-Output "Number of results: $($Results.Count)"
    Write-Output "First result:"
    Write-Output ""
    Write-Output $Results[0]
}