@echo off
setlocal enabledelayedexpansion

:: Pedir la versión/tag (por ejemplo dev1)
set /p VERSION=Enter the version tag (e.g. dev1, 2.1.0): 

:: Pedir el side (cliente o servidor)
:ASK_SIDE
set /p SIDE=Enter the side to export (c for client, s for server): 
if /I "%SIDE%"=="c" (
    set "SIDE_NAME=client"
) else if /I "%SIDE%"=="s" (
    set "SIDE_NAME=server"
) else (
    echo Invalid option. Please enter 'c' for client or 's' for server.
    goto ASK_SIDE
)

:: Ajustar el nombre de salida según el side
if /I "%SIDE_NAME%"=="server" (
    set "OUTPUT_NAME=IR2-server-%VERSION%.zip"
) else (
    set "OUTPUT_NAME=IR2-%VERSION%.zip"
)

set "OUTPUT_PATH=.\%OUTPUT_NAME%"
set "FINAL_DEST=.\out\%OUTPUT_NAME%"

:: Crear carpeta out si no existe
if not exist ".\out" (
    mkdir ".\out"
)

:: Comprobar si el archivo ya existe y pedir confirmación
if exist "%FINAL_DEST%" (
    echo [WARN] File ".\out\%OUTPUT_NAME%" already exists.
    choice /M "Do you want to overwrite it"
    if errorlevel 2 (
        echo Operation cancelled.
        pause
        exit /b
    )
)

echo [BUILD] Exporting pack...
echo [BUILD] Version: %VERSION%
echo [BUILD] Side: %SIDE_NAME%
echo [BUILD] Output: %OUTPUT_NAME%

:: Ejecutar packwiz export
packwiz curseforge export -o "%OUTPUT_PATH%" -s %SIDE_NAME%

timeout /t 1 >nul

:: Verificar que el archivo se creó
if not exist "%OUTPUT_PATH%" (
    echo [ERROR] Export failed or file was not created: %OUTPUT_PATH%
    pause
    exit /b
)

:: Mover a la carpeta out
move /Y "%OUTPUT_PATH%" "%FINAL_DEST%" >nul
if %errorlevel% neq 0 (
    echo [ERROR] Failed to move %OUTPUT_NAME% to .\out\
    pause
    exit /b
)

echo [DONE] Export complete and moved to .\out\%OUTPUT_NAME%
pause
