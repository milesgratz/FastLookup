# FastLookup

PowerShell Module designed to optimize the speed of searching an array.

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
    
The larger the array, the more significant the performance increase from using FastLookup instead of Where-Object. Here are some speed differences when looking for an object in an array using Where-Object vs FastLookup (hashtable index) method: 

    Array with 10000 rows (+6 columns):
    
    Where-Object:   145ms
    FastLookup:     25ms

    Array with 50000 rows (+6 columns):
    
    Where-Object:   973ms
    FastLookup:     53ms

## Example (1 Column Array)

    PS> $array = 1..1000000
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
		
		
## Example (2+ Column Array)

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

## Install

Download [FastLookup.zip](https://github.com/milesgratz/FastLookup/releases/download/v1.0/FastLookup.zip) and extract the contents into `C:\Users\[User]\Documents\WindowsPowerShell\modules\FastLookup` (you may have to create these directories if they don't exist.)

## Releases
* [v1.0](https://github.com/milesgratz/FastLookup/releases/download/v1.0/FastLookup.zip)

## Contributors
* [Miles Gratz](https://github.com/milesgratz)

## Contact
* Blog: [serveradventures.com](http://www.serveradventures.com)
