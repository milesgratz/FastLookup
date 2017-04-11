function Test-FastLookup {
    <#
    .SYNOPSIS
        Lookup a value in an array faster than Where-Object

    .DESCRIPTION
        Improve the speed of looking up a value in an array by creating a hashtable index.
        Good for looking up results in very large arrays or CSV files (e.g Import-Csv)

    .NOTES
        Version:  1.1
        Author:   Miles Gratz
        Creation Date:  April 11, 2017
        Purpose/Change: Initial script development
 
    .OUTPUTS
        1. Creates a sample array
        2. Compares speed of Where-Object vs Get-FastLookup (using Measure-Command)
    
    .EXAMPLE
        
        PS > Test-FastLookup

        Creating 'speedtest' array, total quantity: 50000
        Example object:

        DeviceName   : Device38
        Type         : Security Camera
        IP           : 10.10.128.1
        VLAN         : VLAN85
        Location     : Los Angeles
        Patch Window : Sunday

        Creating hashtable:
        $Hashtable = New-FastLookup -Array $Array -Header "Location"

        --------------------------------------------------------------------------------
        Measuring speed of Where-Object lookup:

        $Array | Where-Object { $_.Location -eq "Chicago" }
        Days         : 0
        Hours        : 0
        Minutes      : 0
        Seconds      : 0
        Milliseconds : 971

        Number of results: 16468
        First result:

        DeviceName   : Device1
        Type         : Network Switch
        IP           : 10.10.128.47
        VLAN         : VLAN90
        Location     : Chicago
        Patch Window : Sunday

        --------------------------------------------------------------------------------
        Measuring speed of Get-FastLookup lookup:

        Get-FastLookup -Value "Chicago" -Array $array -Table $hashtable
        Days         : 0
        Hours        : 0
        Minutes      : 0
        Seconds      : 0
        Milliseconds : 71

        Number of results: 16468
        First result:

        DeviceName   : Device1
        Type         : Network Switch
        IP           : 10.10.128.47
        VLAN         : VLAN90
        Location     : Chicago
        Patch Window : Sunday

        [NOTE] Performance test on Windows 10 x64 (i5-6200U, 8GB RAM, SSD)

    #>
    param(
        # Default sample size of 50K
        [int]$Quantity = 50000
    )

    # Define empty array and index
    $Array = @()
    $Index = 0

    # Create array based on quantity
    Write-Output "Creating 'speedtest' array, total quantity: $Quantity"
    while ($Index -lt $Quantity)
    {
        # Calculate percentage
        $PercentageIndex = $Percentage
        $Percentage = [math]::Round((($Index / $Quantity)*100))

        # Announce percentage
        If ($Percentage -gt $PercentageIndex)
        {
            Write-Output "Creating 'speedtest' array ($Percentage%)"
        }
        
        # Example template
        $DeviceNumber = 1..100 | Get-Random
        $Type = Get-Random 'Laptop','Workstation','Network Switch','Wireless Access Point','Security Camera','Server'
        $IP =  "10.10.128." + (Get-Random (1..254))
        $VLAN = "VLAN" + (Get-Random (1..100))
        $Location = Get-Random 'Chicago','New York','Los Angeles'
        $PatchWindow = Get-Random 'Sunday','Saturday'

        # Create custom object to add to array
        $Object = New-Object PSCustomObject
        $Object | Add-Member -MemberType NoteProperty -name "DeviceName" -Value "Device$DeviceNumber"
        $Object | Add-Member -MemberType NoteProperty -name "Type" -Value "$Type"
        $Object | Add-Member -MemberType NoteProperty -name "IP" -Value "$IP"
        $Object | Add-Member -MemberType NoteProperty -name "VLAN" -Value "$VLAN"
        $Object | Add-Member -MemberType NoteProperty -name "Location" -Value "$Location"
        $Object | Add-Member -MemberType NoteProperty -name "Patch Window" -Value "$PatchWindow"

        # Add object to array
        $Array += $Object
    
        # Increment loop
        $Index++
    }

    # Example object
    Write-Output ""
    Write-Output "Example object:"
    Write-Output $Array[0]

    # Creating New-FastLookup hashtable
    Write-Output ""
    Write-Output "Creating hashtable: "
    Write-Output "" 
    Write-Output ('$Hashtable = New-FastLookup -Array $Array -Header "Location"')
    $Hashtable = New-FastLookup -Array $Array -Header "Location"

    # Measuring speed of Where-Object lookup
    Write-Output ""
    Write-Output ('-'*80)
    Write-Output 'Measuring speed of Where-Object lookup:'
    Write-Output ""
    Write-Output ('$Array | Where-Object { $_.Location -eq "Chicago" }')
    $MeasureWhereObject = Measure-Command { 
        $WhereObjectResults = $Array | Where-Object { $_.Location -eq "Chicago" }
    } | Select Days,Hours,Minutes,Seconds,Milliseconds
    Write-Output $MeasureWhereObject
    Write-Output ""
    Write-Output "Number of results: $($WhereObjectResults.Count)"
    Write-Output "First result:"
    Write-Output ""
    Write-Output $WhereObjectResults[0]
    
    # Measuring speed of Get-FastLookup
    Write-Output ('-'*80)
    Write-Output 'Measuring speed of Get-FastLookup lookup:'
    Write-Output ""
    Write-Output ('Get-FastLookup -Value "Chicago" -Array $array -Table $hashtable')
    $MeasureFastLookup = Measure-Command { 
        $FastLookupResults = Get-FastLookup -Value "Chicago" -Array $Array -Table $Hashtable 
    } | Select Days,Hours,Minutes,Seconds,Milliseconds
    Write-Output ""
    Write-Output $MeasureFastLookup
    Write-Output ""
    Write-Output "Number of results: $($FastLookupResults.Count)"
    Write-Output "First result:"
    Write-Output ""
    Write-Output $FastLookupResults[0]
}
