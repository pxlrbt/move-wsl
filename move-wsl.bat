@echo off

SET WSL_NAME=%1
SET WSL_TARGET=%2
SET TEMP_FILE=%WSL_TARGET%\%WSL_NAME%.tar

SET /P PROMPT= "Move WSL "%WSL_NAME%" to %WSL_TARGET%? (Y|n) "

IF /I "%PROMPT%" NEQ "Y" GOTO END

IF NOT EXIST "%WSL_TARGET%" (
    ECHO Creating target dir "%WSL_TARGET%" ...
    SETLOCAL enableextensions
    MD %WSL_TARGET%
    ENDLOCAL
)

ECHO Exporting VHDX to "%TEMP_FILE%" ...
wsl --export %WSL_NAME% %TEMP_FILE%

ECHO Unregistering WSL ...
wsl --unregister %WSL_NAME% >nul 2>&1

ECHO Importing "%WSL_NAME%" at %WSL_TARGET% ...
wsl --import %WSL_NAME% %WSL_TARGET% %TEMP_FILE%

ECHO Cleaning up ...
DEL %TEMP_FILE%

ECHO Done!

:END
PAUSE
EXIT