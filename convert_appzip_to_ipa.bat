@echo off
REM convert_appzip_to_ipa.bat
REM Uso:
REM   convert_appzip_to_ipa.bat Runner.app.zip

setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Uso: %0 archivo.app.zip
    exit /b 1
)

set INPUT=%~1

if not exist "%INPUT%" (
    echo Error: archivo no encontrado
    exit /b 1
)

set TMPDIR=%TEMP%\ipa_build_%RANDOM%
mkdir "%TMPDIR%"

echo [+] Extrayendo ZIP...

powershell -Command "Expand-Archive -LiteralPath '%INPUT%' -DestinationPath '%TMPDIR%' -Force"

set APPDIR=

for /d /r "%TMPDIR%" %%D in (*.app) do (
    set APPDIR=%%D
    goto :found
)

:found

if "!APPDIR!"=="" (
    echo Error: no se encontro carpeta .app
    rmdir /s /q "%TMPDIR%"
    exit /b 1
)

for %%F in ("!APPDIR!") do (
    set APPNAME=%%~nF
)

mkdir "%TMPDIR%\Payload"

move "!APPDIR!" "%TMPDIR%\Payload\" >nul

set OUTPUT=!APPNAME!.ipa

echo [+] Creando IPA...

powershell -Command ^
"Compress-Archive -Path '%TMPDIR%\Payload' -DestinationPath '%CD%\!OUTPUT!.zip' -Force"

rename "!OUTPUT!.zip" "!OUTPUT!"

echo [+] IPA creada:
echo     !OUTPUT!

rmdir /s /q "%TMPDIR%"