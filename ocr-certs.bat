@echo off
rem Bakes a proper text layer into every PDF under this folder, once.
rem Originals are never touched: searchable copies go to a folder named <this folder>-ocr.
setlocal enabledelayedexpansion
cd /d "%~dp0"
set "SRC=%CD%"
set "DST=%CD%-ocr"

where ocrmypdf >nul 2>nul
if errorlevel 1 goto missing

echo Reading every PDF under  "%SRC%"
echo Writing searchable copies to  "%DST%"
echo.

set /a done=0
set /a failed=0
for /r "%SRC%" %%F in (*.pdf) do (
  set "IN=%%F"
  set "REL=!IN:%SRC%\=!"
  set "OUT=%DST%\!REL!"
  for %%D in ("!OUT!") do if not exist "%%~dpD" mkdir "%%~dpD" >nul 2>nul
  if exist "!OUT!" (
    echo   skipping !REL! ^(already done^)
  ) else (
    echo   !REL!
    rem --redo-ocr throws away the scanner's own OCR and reads the page properly,
    rem while leaving any genuine text in the file alone.
    ocrmypdf --redo-ocr --deskew --rotate-pages --language eng --output-type pdf --quiet "!IN!" "!OUT!"
    if errorlevel 1 (
      echo       could not be read -- copying the original unchanged
      copy /y "!IN!" "!OUT!" >nul
      set /a failed+=1
    ) else (
      set /a done+=1
    )
  )
)

echo.
echo Finished. !done! read, !failed! copied unchanged.
echo Point heat-search.html at  "%DST%"
pause
exit /b

:missing
echo ocrmypdf was not found.
echo.
echo Install it once:    pip install ocrmypdf
echo It also needs Tesseract and Ghostscript - see
echo https://ocrmypdf.readthedocs.io/en/latest/installation.html
pause
