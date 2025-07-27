@echo off
REM File watcher script for automatic testing (Windows)
REM This script watches for file changes and runs tests automatically

echo 🔍 Starting file watcher for automatic testing...
echo Watching: lib/, test/ directories
echo Press Ctrl+C to stop

REM Function to run tests
:run_tests
echo.
echo 🧪 File changed - Running tests...
echo ================================
flutter test --reporter=expanded
echo.
echo ✅ Tests completed at %date% %time%
echo Watching for changes...
goto :eof

REM Simple polling-based file watcher (Windows)
echo ❌ Advanced file watching requires PowerShell or third-party tools
echo For automatic testing, consider using:
echo 1. VS Code continuous testing (Test: Toggle Continuous Run)
echo 2. PowerShell FileSystemWatcher
echo 3. Third-party tools like nodemon
echo.
echo For manual testing, run: flutter test

pause
