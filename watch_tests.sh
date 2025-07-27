#!/bin/bash

# File watcher script for automatic testing
# This script watches for file changes and runs tests automatically

echo "🔍 Starting file watcher for automatic testing..."
echo "Watching: lib/, test/ directories"
echo "Press Ctrl+C to stop"

# Function to run tests
run_tests() {
    echo ""
    echo "🧪 File changed - Running tests..."
    echo "================================"
    flutter test --reporter=expanded
    echo ""
    echo "✅ Tests completed at $(date)"
    echo "Watching for changes..."
}

# Watch for changes in lib and test directories
if command -v fswatch >/dev/null 2>&1; then
    # Use fswatch if available (macOS/Linux)
    fswatch -o lib/ test/ | while read f; do run_tests; done
elif command -v inotifywait >/dev/null 2>&1; then
    # Use inotifywait if available (Linux)
    while inotifywait -r -e modify,create,delete lib/ test/; do
        run_tests
    done
else
    echo "❌ File watcher not available. Install fswatch or inotifywait"
    echo "For manual testing, run: flutter test"
fi
