@echo off
rem Serves this folder so heat-search.html can find the PDFs in it by itself.
rem Put this file next to heat-search.html, in the folder with the certificates.
cd /d "%~dp0"
set PORT=8752

py -3 -c "" >nul 2>nul && goto run_py
python -c "" >nul 2>nul && goto run_python
goto no_python

:run_py
echo Serving this folder at http://localhost:%PORT%/ - close this window when you are done.
start "" "http://localhost:%PORT%/heat-search.html"
py -3 -m http.server %PORT%
goto :eof

:run_python
echo Serving this folder at http://localhost:%PORT%/ - close this window when you are done.
start "" "http://localhost:%PORT%/heat-search.html"
python -m http.server %PORT%
goto :eof

:no_python
echo Python was not found, so the page cannot read this folder on its own.
echo Opening it anyway - use the "Scan a folder" button and pick this folder.
start "" "heat-search.html"
pause
