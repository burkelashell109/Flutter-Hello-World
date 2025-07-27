#!/bin/bash

# Test automation script for Flutter Hello World project
# This script runs different types of tests and generates reports

echo "🧪 Flutter Hello World - Automated Testing Suite"
echo "================================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo -e "${YELLOW}📋 Running Unit Tests...${NC}"
echo "----------------------------------------"
flutter test test/unit/ --reporter=expanded

echo ""
echo -e "${YELLOW}🎯 Running Widget Tests...${NC}"
echo "----------------------------------------"
flutter test test/widget_test.dart --reporter=expanded

echo ""
echo -e "${YELLOW}🖥️ Running Widget Component Tests...${NC}"
echo "----------------------------------------"
flutter test test/widget/ --reporter=expanded

echo ""
echo -e "${YELLOW}🔍 Running Integration Tests...${NC}"
echo "----------------------------------------"
flutter test integration_test/ --reporter=expanded

echo ""
echo -e "${YELLOW}📊 Generating Test Coverage...${NC}"
echo "----------------------------------------"
flutter test --coverage
if [ -f "coverage/lcov.info" ]; then
    echo -e "${GREEN}✅ Coverage report generated in coverage/lcov.info${NC}"
else
    echo -e "${RED}❌ Coverage report generation failed${NC}"
fi

echo ""
echo -e "${YELLOW}🔧 Running Static Analysis...${NC}"
echo "----------------------------------------"
flutter analyze

echo ""
echo "🎯 Test Summary:"
echo "• Unit Tests: Testing utility functions and models"
echo "• Widget Tests: Testing UI components and interactions"  
echo "• Integration Tests: Testing complete app workflows"
echo "• Static Analysis: Code quality and potential issues"
echo ""
echo "✨ Automated testing complete!"
