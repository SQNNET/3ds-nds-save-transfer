function Wait-ForUserPrompt {
    $null = Read-Host
}

function Find-PathAsEnvironmentVariable {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('3DSSAVETRANSFER_PC_FOLDER','3DSSAVETRANSFER_PC_BACKUPS', '3DSSAVETRANSFER_SD_FOLDER', '3DSSAVETRANSFER_SD_BACKUPS')]
        [String]
        $EnvironmentVariable
    )

    $path = [Environment]::GetEnvironmentVariable("$($EnvironmentVariable)", "User")

    if($null -eq $path) {
        $couldNotFindText = ""
        $selectPathText = ""
        switch ($EnvironmentVariable) {
            "3DSSAVETRANSFER_PC_FOLDER" {
                $couldNotFindText = "your PC roms folder"
                $selectPathText = "which contains your PC's roms and saves"
            }
            "3DSSAVETRANSFER_PC_BACKUPS" {
                $couldNotFindText = "your PC save backups"
                $selectPathText = "which contains your PC's save backups"
            }
            "3DSSAVETRANSFER_SD_FOLDER" {
                $couldNotFindText = "your SD card NDS folder"
                $selectPathText = "which contains your SD card's NDS roms"
            }
            "3DSSAVETRANSFER_SD_BACKUPS" {
                $couldNotFindText = "your SD card save backups"
                $selectPathText = "which contains your SD card save backups"
            }
        }
        Write-Warning "Could not find the path associated with $($couldNotFindText). Press enter to open the folder selector:"
        Wait-ForUserPrompt
        $folderName = Get-FolderName -SelectedPath $PWD -Description "Select the folder $($selectPathText)."

        if ($null -eq $folderName) {
            Write-Host "Operation cancelled. No data has been transferred." -ForegroundColor Red
            exit
        }

        Write-Host $folderName
        $answer = Read-Host "Would you like to persist this file path for future runs? (y/n)"

        if ($answer -eq "y" -or $answer -eq "Y") {
            [Environment]::SetEnvironmentVariable($EnvironmentVariable, $folderName, "User")
        }

        return $folderName
    }

    return $path
}

# Pulled from https://github.com/myusefulrepo/Tips/blob/8da8779d41efb663ecb1ef39734a57eea1afe699/Tips%20%20-%20How%20to%20create%20an%20open%20file%20and%20folder%20dialog%20box%20with%20PowerShell.md
Function Get-FolderName {
    <#
    .SYNOPSIS
    Show a Folder Browser Dialog and return the directory selected by the user

    .DESCRIPTION
    Show a Folder Browser Dialog and return the directory selected by the user

    .PARAMETER SelectedPath
    Initial Directory for browsing
    Mandatory - [string]

    .PARAMETER Description
    Message Box Title
    Optional - [string] - Default : "Select a Folder"

    .PARAMETER  ShowNewFolderButton
    Show New Folder Button when unused (default) or doesn't show New Folder when used with $false value
    Optional - [Switch]

    .EXAMPLE
    Get-FolderName
        cmdlet Get-FileFolder at position 1 of the command pipeline
        Provide values for the following parameters:
        SelectedPath: C:\temp
        C:\Temp\

    Choose only one Directory. It's possible to create a new folder (default)

    .EXAMPLE
    Get-FolderName -SelectedPath c:\temp -Description "Select a folder" -ShowNewFolderButton
    C:\Temp\Test

    Choose only one Directory. It's possible to create a new folder

    .EXAMPLE
    Get-FolderName -SelectedPath c:\temp -Description "Select a folder"
    C:\Temp\Test
    Choose only one Directory. It's not possible to create a new folder

    .EXAMPLE
    Get-FolderName  -SelectedPath c:\temp
    C:\Temp\Test

    Choose only one Directory. It's possible to create a new folder (default)


    .EXAMPLE
    Get-Help Get-FolderName -Full

    .INPUTS
    System.String
    System.Management.Automation.SwitchParameter

    .OUTPUTS
    System.String


    .NOTES
    Version         : 1.0
    Author          : O. FERRIERE
    Creation Date   : 12/10/2019
    Purpose/Change  : Initial development

    Based on different pages :
    mainly based on https://blog.danskingdom.com/powershell-multi-line-input-box-dialog-open-file-dialog-folder-browser-dialog-input-box-and-message-box/
    https://code.adonline.id.au/folder-file-browser-dialogues-powershell/
    https://thomasrayner.ca/open-file-dialog-box-in-powershell/
    https://code.adonline.id.au/folder-file-browser-dialogues-powershell/
    #>

    [CmdletBinding()]
        [OutputType([string])]
        Param
        (
            # InitialDirectory help description
            [Parameter(
                Mandatory = $true,
                ValueFromPipelineByPropertyName = $true,
                HelpMessage = "Initial Directory for browsing",
                Position = 0)]
            [String]$SelectedPath,

            # Description help description
            [Parameter(
                Mandatory = $false,
                ValueFromPipelineByPropertyName = $true,
                HelpMessage = "Message Box Title")]
            [String]$Description="Select a Folder",

            # ShowNewFolderButton help description
            [Parameter(
                Mandatory = $false,
                HelpMessage = "Show New Folder Button when used")]
            [Switch]$ShowNewFolderButton
        )

        # Load Assembly
        Add-Type -AssemblyName System.Windows.Forms

        # Open Class
        $FolderBrowser= New-Object System.Windows.Forms.FolderBrowserDialog

    # Define Title
        $FolderBrowser.Description = $Description

        # Define Initial Directory
        if (-Not [String]::IsNullOrWhiteSpace($SelectedPath))
        {
            $FolderBrowser.SelectedPath=$SelectedPath
        }

        if($folderBrowser.ShowDialog() -eq "OK")
        {
            $Folder += $FolderBrowser.SelectedPath
        }
        return $Folder
}

Write-Host -ForegroundColor Green "1) Migrate Saves: SD -> Local Emulator"
Write-Host "Copies .sav files from the SD card to PC storage. Saves backups of the PC's .sav files, just in case."
Write-Host -ForegroundColor Green "`n2) Migrate Saves: Local Emulator -> SD"
Write-Host "Copies .sav files from PC/emulator storage to the SD card. Saves backups of the SD card's .sav files, just in case."
Write-Host -ForegroundColor Green "`n3) Copy Local ROMs to SD Card"
Write-Host "Copies all missing .nds files from PC storage onto the SD card. Duplicates will not be processed. No .nds files will be deleted from the SD card as part of this process."
Write-Host -ForegroundColor Green "`n4) Clear any saved file paths"
Write-Host "File paths are saved within your user's environment variables. If you'd like to clear and re-enter them on a later run, choose this option."

Write-Host -ForegroundColor Blue "`nWhich operation would you like to perform?"
$promptedChoice = Read-Host

switch ($promptedChoice) {
    1 {
        # grab or populate folder information depending on whether or not it exists
        $pcPath = Find-PathAsEnvironmentVariable -EnvironmentVariable "3DSSAVETRANSFER_PC_FOLDER"
        $pcBackupsPath = Find-PathAsEnvironmentVariable -EnvironmentVariable "3DSSAVETRANSFER_PC_BACKUPS"
        $sdPath = Find-PathAsEnvironmentVariable -EnvironmentVariable "3DSSAVETRANSFER_SD_FOLDER"

        Write-Host -ForegroundColor Blue "Copying melonDS files to a backup folder, just in case..."
        Get-ChildItem -LiteralPath $pcPath -Filter "*.sav" | Copy-Item -Destination $pcBackupsPath -Verbose
        
        Write-Host -ForegroundColor Blue "Copying SD .sav files over to melonDS..."
        
        Get-ChildItem -LiteralPath "$sdPath\saves" -Filter "*.sav" | Copy-Item -Destination $pcPath -Verbose
        
        Write-Host -ForegroundColor Blue "Finished! Press enter to exit."
        Wait-ForUserPrompt
    }
    2 {
        # grab or populate folder information depending on whether or not it exists
        $pcPath = Find-PathAsEnvironmentVariable -EnvironmentVariable "3DSSAVETRANSFER_PC_FOLDER"
        $sdBackupsPath = Find-PathAsEnvironmentVariable -EnvironmentVariable "3DSSAVETRANSFER_SD_BACKUPS"
        $sdPath = Find-PathAsEnvironmentVariable -EnvironmentVariable "3DSSAVETRANSFER_SD_FOLDER"

        Write-Host -ForegroundColor Blue "Copying SD files to a backup folder, just in case..."
        mkdir -Force "$sdBackupsPath\saves" | Out-Null
        Get-ChildItem -LiteralPath "$sdPath\saves" -Filter "*.sav" | Copy-Item -Destination "$sdBackupsPath\saves" -Verbose
        
        Write-Host -ForegroundColor Blue "Copying .sav files over to the SD card..."
        
        Get-ChildItem -LiteralPath $pcPath -Filter "*.sav" | Copy-Item -Destination "$sdPath\saves" -Verbose
        
        Write-Host -ForegroundColor Blue "Finished! Press enter to exit."
        Wait-ForUserPrompt
    }
    3 {
        # grab or populate folder information depending on whether or not it exists
        $pcPath = Find-PathAsEnvironmentVariable -EnvironmentVariable "3DSSAVETRANSFER_PC_FOLDER"
        $sdPath = Find-PathAsEnvironmentVariable -EnvironmentVariable "3DSSAVETRANSFER_SD_FOLDER"

        Write-Host -ForegroundColor Blue "Copying ROMs over to the SD card..."
        $exclude = Get-ChildItem -Recurse $sdPath
        Get-ChildItem -LiteralPath $pcPath -Filter "*.nds" | Copy-Item -Destination $sdPath -Verbose -Exclude $exclude

        Write-Host -ForegroundColor Blue "Finished! Press enter to exit."
        Wait-ForUserPrompt
    }
    4 {
        [Environment]::SetEnvironmentVariable("3DSSAVETRANSFER_PC_FOLDER", $null, "User")
        [Environment]::SetEnvironmentVariable("3DSSAVETRANSFER_PC_BACKUPS", $null, "User")
        [Environment]::SetEnvironmentVariable("3DSSAVETRANSFER_SD_FOLDER", $null, "User")
        [Environment]::SetEnvironmentVariable("3DSSAVETRANSFER_SD_BACKUPS", $null, "User")

        Write-Host -ForegroundColor Blue "Finished! Press enter to exit."
        Wait-ForUserPrompt
    }
    default {
        Exit
    }
}