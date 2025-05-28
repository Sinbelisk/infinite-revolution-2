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

echo [INFO] Current ATLauncher profile base path:
echo [INFO] %ORIGIN_BASE%
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
    set /a COUNT=1
    :FIND_UNIQUE
    if exist "mods_old_%COUNT%" (
        set /a COUNT+=1
        goto FIND_UNIQUE
    )
    echo [BACKUP] Backing up existing mods folder to "mods_old_%COUNT%"...
    ren "%MOD_FOLDER%" "mods_old_%COUNT%"
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
