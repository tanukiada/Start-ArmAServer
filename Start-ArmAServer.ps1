<#
    .SYNOPSIS
    start.ps1 handles all server start, stop, and restart functions. it can also be used for quickly switching presets

    .PARAMETER StartServer
    Starts the server, checking if it's already running

    .PARAMETER RestartServer
    Restarts the server, again checking if it's already running

    .PARAMETER StopServer
    Stops The server, as usual checking if it's actually running first

    .PARAMETER ModList
    Sets active commandline based on textfile listed
#>

param (
    [switch]$StartServer,
    [switch]$RestartServer,
    [switch]$StopServer,
    [string]$New,
    [string[]]$ModList
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

}

function Start-ArmAServer($mods) {
    ./arma3server_x64.exe "-name=server" "-filePatching" "-config=server.cfg" "-cfg=basic.cfg" "-mod=$mods" "-servermod=@AdvancedUrbanRappelling;@AdvancedRappelling;@AdvancedSlingLoading;@AdvancedTowing"
}

function Stop-ArmaServer {
    if (Test-Running -ne 1) {
        Stop-Process(Get-PID)
    } else {
        Write-Error -Message "Server Not Running" -Category ResourceUnavailable
    }
}

function Get-Mods {
    if ((Test-Path -Path $ModList)) {
        return Get-Content -Path $ModList
    } else {
        Write-Error -Message "No mods text file. Does it exist?" -Category ResourceUnavailable
        Exit
    }
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