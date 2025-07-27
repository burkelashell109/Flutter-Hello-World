@echo off
REM Test automation script for Flutter Hello World project (Windows)
REM This script runs different types of tests and generates reports

echo 🧪 Flutter Hello World - Automated Testing Suite
echo =================================================

echo.
echo 📋 Running Unit Tests...
echo ----------------------------------------
flutter test test/unit/ --reporter=expanded

echo.
echo 🎯 Running Widget Tests...
echo ----------------------------------------
flutter test test/widget_test.dart --reporter=expanded

echo.
echo 🖥️ Running Widget Component Tests...
echo ----------------------------------------
flutter test test/widget/ --reporter=expanded

echo.
echo 🔍 Running Integration Tests...
echo ----------------------------------------
flutter test integration_test/ --reporter=expanded

echo.
echo 📊 Generating Test Coverage...
echo ----------------------------------------
flutter test --coverage
if exist "coverage\lcov.info" (
    echo ✅ Coverage report generated in coverage\lcov.info
) else (
    echo ❌ Coverage report generation failed
)

echo.
echo 🔧 Running Static Analysis...
echo ----------------------------------------
flutter analyze

echo.
echo 🎯 Test Summary:
echo • Unit Tests: Testing utility functions and models
echo • Widget Tests: Testing UI components and interactions  
echo • Integration Tests: Testing complete app workflows
echo • Static Analysis: Code quality and potential issues
echo.
echo ✨ Automated testing complete!

pause
