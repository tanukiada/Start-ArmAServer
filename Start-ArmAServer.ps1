<#
    .SYNOPSIS
    start.ps1 handles all server start, stop, and restart functions. it can also be used for quickly switching presets

    .PARAMETER StartServer
    Starts the server, checking if it's already running

    .PARAMETER RestartServer
    Restarts the server, again checking if it's already running

    .PARAMETER StopServer
    Stops The server, as usual checking if it's actually running first

    .PARAMETER New
    Creates new preset folder and moves all mods currently in main directory into it

    .PARAMETER Enable
    Moves named preset from it's sub directory to main directory

    .PARAMETER Disable
    Moves named preset from main directory to sub directory

    .PARAMETER Switch
    Moves first named preset into it's sub folder and second named preset into main folder
#>

param (
    [switch]$StartServer,
    [switch]$RestartServer,
    [switch]$StopServer,
    [string]$New,
    [string]$Enable,
    [string]$Disable,
    [string[]]$Switch
)

function main {
    if ($StartServer) {
        If (Test-Running -ne 1) {
            Write-Output -InputObject "Server already running"
        } else {
            Start-ArmAServer(Get-Mods)
        }
    }
    
    if ($StopServer) {
        if (Test-Running -eq 1) {
            Stop-ArmAServer
        } else {
            Write-Output -InputObject "Server not running"
        }
    }
    
    if ($RestartServer) {
        if (Test-Running -eq 1) {
            Stop-ArmaServer
            Start-ArmAServer(Get-Mods)
        } else {
            Write-Output -InputObject "Server not running"
        }
        
    }
    
    if ($New) {
        New-Preset
    }

    if ($Enable) {
        Enable-Preset($Enable)
    }
    
    if ($Disable) {
        Disable-Preset($Disable)
    }
    
    if ($Switch) {
        Switch-Preset($Switch[0], $Switch[1])
    }
}

function Start-ArmAServer($mods) {
    ./arma3server_x64.exe "-name=server" "-config=server.cfg" "-cfg=basic.cfg" "-mod=$mods"}

function Stop-ArmaServer {
    if (Test-Running -ne 1) {
        Stop-Process(Get-PID)
    } else {
        Write-Error -Message "Server Not Running" -Category ResourceUnavailable
    }
}

function New-Preset {
    New-Item -Path "C:\Arma 3\" -Name "PRESET_$New" -ItemType "directory"

    $modlist = Get-ChildItem "C:\Arma 3" | where-object {$_.Name -like '@*'}
    $modlist -join ';' | Out-File 'mods.txt'
}

function Get-Mods {
    if ((Test-Path -Path .\mods.txt)) {
        return Get-Content -Path .\mods.txt
    } else {
        Write-Error -Message "No mods.txt. Does it exist?" -Category ResourceUnavailable
        Exit
    }
}

function Enable-Preset($preset) {
    Move-Item -Path "C:\Arma 3\$preset\@*" -Destination "C:\Arma 3\"
    Move-Item -Path "C:\Arma 3\$preset\mods.txt" -Destination "C:\Arma 3\"
}

function Disable-Preset($presetDisable) {
    Move-Item -Path "C:\Arma 3\@*" -Destination $presetDisable
    Move-Item -Path "C:\Arma 3\mods.txt" -Destination $presetDisable
}

function Switch-Preset($oldPreset, $newPreset) {
    Move-Item -Path "$newPreset/@*" -Destination "C:\Arma 3\"
    Move-Item -Path "$newPreset/mods.txt" -Destination "C:\Arma 3\" -Force
    Move-Item -Path "c:\Arma 3\@*" -Destination $oldPreset -Force
    Move-Item -Path "c:\Arma 3\mods.txt" -Destination $oldPreset -Force
}

function Get-PID {
    $armaRunning = Get-Process arma3server_x64 -ErrorAction SilentlyContinue
    if ($armaRunning) {
        return (Get-Process arma3server_x64).Id
    }
}

function Test-Running {
    $armaPID = Get-PID
    if ($armaPID -ne 0) {
        return $armaPID
    } else {
        return 1
    }
}

function Compare-PID {
    $armaPid = Test-Running
    if ($armaPid -ne 1) {
        return 0
    } else {
        return 1
    }
}

main