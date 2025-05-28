@echo off
setlocal

:: Config file that stores the base profile path
set "CONFIG_FILE=sync_conf.cfg"

:: Load ORIGIN_BASE path from config if it exists
if exist "%CONFIG_FILE%" (
    set /p ORIGIN_BASE=<"%CONFIG_FILE%"
) else (
    echo [SETUP] No saved profile base path found.
    set /p ORIGIN_BASE="Please enter the base path to your ATLauncher profile folder (e.g. C:\Users\YourName\AppData\Roaming\ATLauncher\instances\YourProfile): "
    echo %ORIGIN_BASE%>"%CONFIG_FILE%"
    echo [SETUP] Path saved to %CONFIG_FILE%.
)

:: Full path to the mods folder
set "ORIGIN=%ORIGIN_BASE%\mods"
:: Destination folder (new mods folder)
set "MOD_FOLDER=.\mods"
:: Backup folder
set "BACKUP_DIR=backup"

echo [INFO] Full source mods folder path: %ORIGIN%

echo [INFO] This script will sync the mods from the IR2 ATLauncher profile.
echo [INFO][WARN] The original mods folder will be deleted and replaced.
set /p CONFIRM="Do you want to continue? (Y/N): "
if /I not "%CONFIRM%"=="Y" (
    echo Operation cancelled.
    exit /b
)


:: Create a backup if the destination folder exists
if exist "%MOD_FOLDER%" (
    if not exist "%BACKUP_DIR%" (
        mkdir "%BACKUP_DIR%"
    )

    :: First backup: mods_old (no number)
    if not exist "%BACKUP_DIR%\mods_old" (
        echo [BACKUP] Backing up existing mods folder to "%BACKUP_DIR%\mods_old"...
        move "%MOD_FOLDER%" "%BACKUP_DIR%\mods_old" >nul
    ) else (
        :: Find next available numbered backup
        set /a COUNT=1
        :FIND_UNIQUE
        if exist "%BACKUP_DIR%\mods_old_%COUNT%" (
            set /a COUNT+=1
            goto FIND_UNIQUE
        )
        echo [BACKUP] Backing up existing mods folder to "%BACKUP_DIR%\mods_old_%COUNT%"...
        move "%MOD_FOLDER%" "%BACKUP_DIR%\mods_old_%COUNT%" >nul
    )
)

echo [COPY] Copying folder from "%ORIGIN%" to "%MOD_FOLDER%"...

:: Copy the folder and its contents
xcopy "%ORIGIN%" "%MOD_FOLDER%" /E /I /H /Y

echo [COPY] Copy complete.

:: Run packwiz command
echo [PACKWIZ] [SYNC] Syncing mods...
packwiz curseforge detect

echo [PACKWIZ] [FINISHING] Refreshing index...
packwiz refresh

pause
