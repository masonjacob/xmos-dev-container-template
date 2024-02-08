# Attach/Detach XTAG Device to WSL, run UDEV rules
function Convert-WindowsPathToWSLPath {
    # Function to convert Windows Path to WSL Path
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$WindowsPath
    )
    # Convert drive part to /mnt/<lowercase drive letter>/
    $lowercaseChar = $WindowsPath[0].toString()
    $lowercaseChar = $lowercaseChar.ToLower()
    $WSLPath = $lowercaseChar + $WindowsPath.Substring(1)
    $WSLPath = $WSLPath -replace '^([A-Z]):\\', '/mnt/$1/'
    # Convert backslashes to forward slashes
    $WSLPath = $WSLPath -replace '\\', '/'
    # Add \ before any spaces
    $WSLPath = $WSLPath -replace ' ', '\ '
    return $WSLPath
}

function Add-UDEV-Rules-To-WSL {

    # Add UDEV rules
    $wslPath = Convert-WindowsPathToWSLPath -WindowsPath $PWD.Path
    $udevPath = "/etc/udev/rules.d"

    $udevContents = wsl ls $udevPath
    if ($udevContents -match "99-xmos.rules") {
        
    } else {
        wsl sudo cp "$wslPath/scripts/99-xmos.rules" $udevPath 
        wsl sudo service udev reload
        # wsl udevadm control --reload
        # wsl udevadm trigger
    }

    # $tempPath = "/tmp/scripts"
    # wsl mkdir $tempPath
    # wsl cp "$wslPath\setup_xmos_devices.sh" $tempPath
    # wsl cp "$wslPath\check_xmos_devices.sh" $tempPath
    # wsl chmod +x $tempPath/setup_xmos_devices.sh
    # wsl chmod +x $tempPath/check_xmos_devices.sh
    # wsl sudo -e $tempPath/setup_xmos_devices.sh
    # wsl sudo -e $tempPath/check_xmos_devices.sh

    # wsl sudo rm $tempPath -r -f
}

function Find-XTAG-Devices {
    # Run the `usbipd wsl list` command and capture its output
    $usbipdOutput = usbipd wsl list
    # Use the Where-Object cmdlet to filter the list based on the DEVICE name
    $filteredDevices = $usbipdOutput | Where-Object { $_ -match "XMOS XTAG-4" }
    # Extract BUSID from the filtered list
    $busids = $filteredDevices | ForEach-Object {
        # Split the line by whitespace and take the first element (BUSID)
        $busid = ($_ -split '\s+')[0]
        $busid
    }
    return $busids
}

function Install {

}

function Attach {
    $busids = Find-XTAG-Devices
    # Attach the busids to WSL
    foreach ($busid in $busids) {
        usbipd wsl attach --busid $busid
    }
}
function Detach {
    $busids = Find-XTAG-Devices
    # Detach the busids from WSL
    if ($busids.Count -eq 0) {
        Write-Host "No XTAG devices were found to detach from WSL. Exiting..."
        exit 1
    }
    foreach ($busid in $busids) {
        usbipd wsl detach --busid $busid
    }
}

function Show-Usage {
    Write-Host 
"Usage: configure.ps1 [options?]`r`n
Options:`r
`t<none>`t`t add UDEV rules and attach XTAG device to WSL`r
`t--install`t Install USBIPD-WIN via winget`r
`t--attach`t Attach XTAG device to WSL`r
`t--detach`t Detach XTAG device from WSL`r
`t--add-rules`t Add UDEV rules to WSL`r
`t--help`t`t Show this help message`r`n"
    exit 1
}

# Check if required parameters are provided
if ($args.Count -ne 0) {
    foreach ($arg in $args) {
        if ($arg -eq "--attach") {
            Attach
        } elseif ($arg -eq "--detach") {
            Detach
        } elseif ($arg -eq "--add-rules") {
            Add-UDEV-Rules-To-WSL
        } else {
            Show-Usage
        }
    }
} else {
    Add-UDEV-Rules-To-WSL
    Attach
}




