@echo off
SETLOCAL

SET WSL_NAME=%~1
SET WSL_TARGET=%~2

IF %WSL_TARGET:~-1%==\ SET WSL_TARGET=%WSL_TARGET:~0,-1%
SET TEMP_FILE=%WSL_TARGET%\%WSL_NAME%.tar

SET /P PROMPT="Move WSL '%WSL_NAME%' to '%WSL_TARGET%'? (Y|n) "
IF /I "%PROMPT%" NEQ "Y" GOTO :EOF

IF NOT EXIST "%WSL_TARGET%" (
    ECHO Creating target dir "%WSL_TARGET%" ...
    SETLOCAL enableextensions
    MD "%WSL_TARGET%"
    ENDLOCAL
)

ECHO Exporting VHDX to "%TEMP_FILE%" ...
wsl --export %WSL_NAME% "%TEMP_FILE%"

IF %ERRORLEVEL% EQU 0 IF EXIST "%TEMP_FILE%" (
    ECHO Export successful.
    GOTO :UNREGISTER
)
ECHO ERROR: Export failed!
CALL :CLEANUP
GOTO :EOF

:UNREGISTER
ECHO Unregistering WSL ...
wsl --unregister %WSL_NAME% >nul 2>&1

ECHO Importing "%WSL_NAME%" at "%WSL_TARGET%" ...
wsl --import "%WSL_NAME%" "%WSL_TARGET%" "%TEMP_FILE%"

ECHO Validating import ...
IF NOT EXIST "%WSL_TARGET%\ext4.vhdx"  (
    IF NOT EXIST "%WSL_TARGET%\rootfs"  (
        ECHO ERROR: Import failed! Target file not found. Export file at '%TEMP_FILE%'
        GOTO :EOF
    )
)

:CLEANUP
ECHO Cleaning up ...
IF EXIST "%TEMP_FILE%" DEL "%TEMP_FILE%"

ECHO Done!
