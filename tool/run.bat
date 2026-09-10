@echo off
setlocal enabledelayedexpansion
rem Load GEMINI_API_KEY from .env and pass it to flutter as --dart-define.
rem Usage: tool\run.bat [device-id]     -> flutter run
rem        tool\run.bat --build          -> flutter build appbundle --release

if not exist ".env" (
  echo Error: .env not found. Copy .env.example to .env and set GEMINI_API_KEY.
  exit /b 1
)

set "KEY="
for /f "usebackq tokens=1,* delims==" %%a in (".env") do (
  if "%%a"=="GEMINI_API_KEY" set "KEY=%%b"
)

if "%KEY%"=="" (
  echo Error: GEMINI_API_KEY is empty in .env
  exit /b 1
)

rem Trim surrounding whitespace / quotes if any were edited in.
set "KEY=%KEY:"=%"

if "%1"=="--build" (
  flutter build appbundle --release --dart-define=GEMINI_API_KEY=%KEY%
) else if "%1"=="--apk" (
  flutter build apk --release --dart-define=GEMINI_API_KEY=%KEY%
) else if "%1"=="--debug" (
  flutter run -d %2 --dart-define=GEMINI_API_KEY=%KEY%
) else (
  flutter run -d %1 --dart-define=GEMINI_API_KEY=%KEY%
)
endlocal
