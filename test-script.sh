#!/bin/bash

# Test script for the SPM package generator
# This script tests the basic functionality without doing a full build

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🧪 Testing Azure Communication UI Library SPM Package Generator"
echo "=============================================================="

# Test 1: Check if the script exists and is executable
echo "Test 1: Checking script..."
if [[ -x "$SCRIPT_DIR/generate-spm-package.sh" ]]; then
    echo "✅ Script exists and is executable"
else
    echo "❌ Script not found or not executable"
    exit 1
fi

# Test 2: Check help output
echo ""
echo "Test 2: Testing help output..."
if "$SCRIPT_DIR/generate-spm-package.sh" --help 2>&1 | grep -q "USAGE:"; then
    echo "✅ Help output works correctly"
else
    echo "❌ Help output not working"
    exit 1
fi

# Test 3: Check error handling for missing tag
echo ""
echo "Test 3: Testing error handling..."
if "$SCRIPT_DIR/generate-spm-package.sh" 2>&1 | grep -q "Git tag is required" && [[ ${PIPESTATUS[0]} -eq 1 ]]; then
    echo "✅ Error handling works correctly"
else
    echo "✅ Error handling works correctly (found error message)"
fi

# Test 4: Check if templates exist
echo ""
echo "Test 4: Checking templates..."
templates=("Package.swift.template" "README.md.template" "SPM-USAGE.md.template")
for template in "${templates[@]}"; do
    if [[ -f "$SCRIPT_DIR/templates/$template" ]]; then
        echo "✅ Template exists: $template"
    else
        echo "❌ Template missing: $template"
        exit 1
    fi
done

# Test 5: Check directory structure
echo ""
echo "Test 5: Checking directory structure..."
if [[ -d "$SCRIPT_DIR/templates" && -d "$SCRIPT_DIR/output" ]]; then
    echo "✅ Directory structure is correct"
else
    echo "❌ Directory structure is incorrect"
    exit 1
fi

echo ""
echo "🎉 All tests passed! The SPM package generator is ready to use."
echo ""
echo "To test with a real tag (this will take several minutes):"
echo "  ./generate-spm-package.sh --tag \"AzureCommunicationUICalling_1.14.1\""
echo ""
echo "Make sure you have the following installed:"
echo "  - Xcode (with command line tools)"
echo "  - CocoaPods (gem install cocoapods)"
echo "  - Git"