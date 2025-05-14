$pcPath = "M:\Emulation\melonDS\roms"
$pcBackupPath = "M:\Emulation\melonDS\saveFileBackups"
$sdPath = "E:\roms\nds"
$sdBackupPath = "E:\scriptBackups"

Write-Host -ForegroundColor Green "1) Migrate Saves: SD -> Local Emulator`n2) Migrate Saves: Local Emulator -> SD`n3) Copy Local ROMs to SD Card"
$promptedChoice = Read-Host "Which operation would you like to perform?"

switch ($promptedChoice) {
    1 {
        Write-Host -ForegroundColor Blue "Copying melonDS files to a backup folder, just in case..."
        mkdir -Force $pcBackupPath | Out-Null
        Get-ChildItem -LiteralPath $pcPath -Filter "*.sav" | Copy-Item -Destination $pcBackupPath -Verbose
        
        Write-Host -ForegroundColor Blue "Copying .sav files over to melonDS..."
        
        Get-ChildItem -LiteralPath "$sdPath\saves" -Filter "*.sav" | Copy-Item -Destination $pcPath -Verbose
        
        Write-Host -ForegroundColor Blue "Finished!"
    }
    2 {
        Write-Host -ForegroundColor Blue "Copying SD files to a backup folder, just in case..."
        mkdir -Force "$sdBackupPath\saves" | Out-Null
        Get-ChildItem -LiteralPath "$sdPath\saves" -Filter "*.sav" | Copy-Item -Destination "$sdBackupPath\saves" -Verbose
        
        Write-Host -ForegroundColor Blue "Copying .sav files over to the SD card..."
        
        Get-ChildItem -LiteralPath $pcPath -Filter "*.sav" | Copy-Item -Destination "$sdPath\saves" -Verbose
        
        Write-Host -ForegroundColor Blue "Finished!"
    }
    3 {
        Write-Host -ForegroundColor Blue "Copying ROMs over to the SD card..."
        $exclude = Get-ChildItem -Recurse $sdPath
        Get-ChildItem -LiteralPath $pcPath -Filter "*.nds" | Copy-Item -Destination $sdPath -Verbose -Exclude $exclude
        Write-Host -ForegroundColor Blue "Finished!"
    }
    default {
        Exit
    }
}

