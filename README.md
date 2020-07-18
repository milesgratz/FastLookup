# FastLookup

PowerShell Module designed to optimize the speed of searching an array.
	
## Install

### PowerShell Gallery Install (Requires PowerShell v5)

	Install-Module -Name FastLookup

See the [PowerShell Gallery](https://www.powershellgallery.com/packages/FastLookup/) for the complete details and instructions.

### Manual Install

Download [FastLookup.zip](https://github.com/milesgratz/FastLookup/releases/download/v1.2/FastLookup.zip) and extract the contents into `C:\Users\[User]\Documents\WindowsPowerShell\modules\FastLookup` (you may have to create these directories if they don't exist.)

## How It Works?

The <b>FastLookup</b> module creates a hashtable, combining the Values in an array with the Index of the item in the array. Since the Name (or "Key") of the hashtable must be unique, each duplicate result is appended in the hashtable: 

    PS> $array
    
    Laptop
    Workstation
    Laptop
    Router
    
    PS> $hashtable
    
    Name                           Value
    ----                           -----   
    Laptop                         0,2
    Workstation                    1
    Router                         3
 
By creating a dictionary of Values and their Index locations, we can find the Values faster in the hashtable without enumerating the entire array. The larger the array, the more significant the performance increase:  

	Searching for 100 objects in 1,000 row array: 
	
    Where-Object:   	0 hr, 0 min, 0 sec, 40 ms
	Foreach/If Loop:   	0 hr, 0 min, 0 sec, 22 ms
    FastLookup:   	   	0 hr, 0 min, 0 sec, 84 ms
	
	Searching for 1,000 objects in 10,000 row array: 
	
    Where-Object:   	0 hr, 0 min, 1 sec, 687 ms
	Foreach/If Loop:   	0 hr, 0 min, 1 sec, 633 ms
    FastLookup:   	   	0 hr, 0 min, 0 sec, 806 ms
	
	Searching for 10,000 objects in 100,000 row array: 
	
    Where-Object:   	0 hr, 4 min, 18 sec, 366 ms
	Foreach/If Loop:   	0 hr, 4 min, 14 sec, 148 ms
    FastLookup:   	   	0 hr, 0 min, 52 sec, 773 ms

	Searching for 100,000 objects in 1,000,000 row array: 
	
    Where-Object:   	23 hr, 26 min, 31 sec, 789 ms
	Foreach/If Loop:   	23 hr, 44 min, 12 sec, 430 ms
    FastLookup:   	   	 1 hr, 37 min, 16 sec, 874 ms

Performance test on Windows 10 x64 (i5-6200U/8GB/SSD)
	
## Examples

### 1 Column Array

    PS> $array = 1..1000000
    PS> $hashtable = New-FastLookup $array 
    PS> Get-FastLookup -Value 199999 -Array $array -Table $hashtable

### 2+ Column Array

    PS> $array

    DeviceName   : Device38
    Type         : Security Camera
    IP           : 10.10.128.1
    VLAN         : VLAN85
    Location     : Los Angeles
    Patch Window : Sunday
    
    DeviceName   : Device68
    Type         : Server
    IP           : 10.10.128.126
    VLAN         : VLAN15
    Location     : Chicago
    Patch Window : Sunday

    PS> $Hashtable = New-FastLookup -Array $Array -Header "Location"
    PS> Get-FastLookup -Value "Chicago" -Array $Array -Table $Hashtable
    
    DeviceName   : Device68
    Type         : Server
    IP           : 10.10.128.126
    VLAN         : VLAN15
    Location     : Chicago
    Patch Window : Sunday        

### Performance Results
* see [Test-FastLookup](Test-FastLookup.ps1) file

## Releases
* [v1.2](https://github.com/milesgratz/FastLookup/releases/download/v1.2/FastLookup.zip)
* [v1.1](https://github.com/milesgratz/FastLookup/releases/download/v1.1/FastLookup.zip)

## TODO
* see [TODO](TODO.md) file

## Contributors
* [Miles Gratz](https://github.com/milesgratz)

## Contact
* Blog: <redacted due to my old blog domain has been parked by bad actors>
