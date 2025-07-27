# PowerShell File Watcher for Flutter Tests
# This script automatically runs tests when Dart files change

Write-Host "🔍 Starting Flutter Test File Watcher..." -ForegroundColor Cyan
Write-Host "Watching: lib/, test/ directories" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

# Function to run tests
function Run-Tests {
    Write-Host ""
    Write-Host "🧪 File changed - Running tests..." -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Gray
    
    try {
        flutter test --reporter=expanded
        Write-Host ""
        Write-Host "✅ Tests completed at $(Get-Date)" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Test execution failed: $_" -ForegroundColor Red
    }
    
    Write-Host "Watching for changes..." -ForegroundColor Yellow
}

# Create FileSystemWatcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $PWD
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

# Define filters for Dart files
$watcher.Filter = "*.dart"

# Define event handlers
$action = {
    $path = $Event.SourceEventArgs.FullPath
    $changeType = $Event.SourceEventArgs.ChangeType
    
    # Only watch lib/ and test/ directories
    if ($path -match "(lib|test)[\\\/].*\.dart$") {
        Write-Host "📝 File $changeType: $path" -ForegroundColor Gray
        
        # Debounce: wait a bit for multiple rapid changes
        Start-Sleep -Milliseconds 500
        Run-Tests
    }
}

# Register event handlers
Register-ObjectEvent -InputObject $watcher -EventName "Changed" -Action $action
Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action $action
Register-ObjectEvent -InputObject $watcher -EventName "Deleted" -Action $action

# Run initial tests
Run-Tests

# Keep script running
try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
}
finally {
    # Cleanup
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
    Write-Host "🛑 File watcher stopped." -ForegroundColor Red
}
