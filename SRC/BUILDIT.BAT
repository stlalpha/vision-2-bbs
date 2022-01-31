@ECHO OFF
echo ViSiON/2:Resurrection Master Build Script
echo (c)2022 stlalpha - all rights reserved


set BINHOME=c:\v2res\bins
set SRCHOME=C:\v2res\srcball
set ARCHIVEDIR=E:\V2R-ARC

REM Date Functions
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"

set "datestamp=%YYYY%%MM%%DD%" & set "timestamp=%HH%%Min%%Sec%"
set "fullstamp=%YYYY%-%MM%-%DD%_%HH%:%Min%:%Sec%"

REM echo datestamp: "%datestamp%"
REM echo timestamp: "%timestamp%"
REM echo fullstamp: "%fullstamp%"


set /p BuildId="Enter Build ID: "
mkdir %BINHOME%\%BuildId%

set /p BuildCmt="Enter Build Comment: "
echo ----Build ID: %BuildId% - DateStamp: %FullStamp%------ >> V2R-HIST.LOG
echo %BuildCmt% >> V2R-HIST.LOG
echo -------------------------------------------------------- >> V2R-HIST.LOG

echo Hashing src contents...
echo ViSiON2:RES Build ID: %BuildID% > SHA-%BuildId%.LOG
echo %FULLSTAMP% >> SHA-%BuildId%.LOG
sha256deep.exe *.* >> SHA-%BuildID%.LOG

ECHO Compressing source...


pkzip -rP %SRCHOME%\V2R-%BuildID%.ZIP *.* | find "ERROR" >nul2>nul
if not ERRORLEVEL 1 (
echo. Uh oh - build pkzip archive had an error
exit /b 1
)


del SHA-%BuildID%.LOG




attrib +r %SRCHOME%\V2R-%BuildID%.ZIP | find "ERROR" >nul2>nul
if not ERRORLEVEL 1 (
echo. Uh oh - attrib set failed on srcball
exit /b 1
)

COPY %SRCHOME%\V2R-%BuildID%.ZIP %ARCHIVEDIR% | find "ERROR" >nul2>nul
if not ERRORLEVEL 1 (
echo. Uh oh - archive copy of build failed
exit/b 1
)

ATTRIB +r %ARCHIVEDIR%\V2R-%BuildID%.ZI | find "ERROR" >nul2>nul
if not ERRORLEVEL 1 (
echo. Uh oh - setting readonly bit on archived copy failed
exit /b 1
)

FOR /F "tokens=*" %%g IN ('sha256deep.exe %SRCHOME%\V2R-%BuildId%.ZIP') do (SET SHA256=%%g)

ECHO **********************
ECHO Building Id: %BuildId%
ECHO SHA-256: %sha256%
ECHO Sending bins to %BinHome%\%BuildId%

echo ********************* >> %BuildID%-BLD.LOG
echo ViSiON/2:RES Build Log >> %BuildID%-BLD.LOG
echo %fullstamp% >> %BuildID%-BLD.LOG
echo %sha256% >> %BuildID%-BLD.LOG
echo ********************* >> %BuildID%-BLD.LOG
ECHO Build Logged to %BuildID%-BLD.LOG


REM BUILD IT
REM **********************

CALL MAKEALL.BAT %BinHome%\%BuildId% | find "ERROR" >nul2>nul
if not ERRORLEVEL 1 (
echo. ************************
echo. ********FAILBOAT********
echo. build has errors, homey
echo. ************************
exit /b 1
)
echo Write-protecting bin dir
attrib +r %BinHome%\%buildId%\*.* | find "ERROR" >nul2>nul
if not ERRORLEVEL 1 (
echo. Uh oh - write-protect bindir failed
exit /b 1
)

echo Write-protecting archive dir
attrib +r %ArchiveDir%\V2R-%BuildId%.ZIP | find "ERROR" >nul2>nul
if not ERRORLEVEL 1 (
echo. Uh oh - write-protect bindir failed
exit /b 1
)

echo ***********************************
copy %BuildID%-BLD.LOG %BinHome%\%BuildId%
echo Removing local copy of buildlog
del %BuildID%-BLD.LOG | find "ERROR" >nul2>nul
if not ERRORLEVEL 1 (
echo. Uh oh - deleting local build log filed
exit /b 1
)


