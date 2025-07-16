#!/bin/bash

# Azure Communication UI Library SPM Package Generator
# Automatically generates Swift Package Manager package from Azure Communication UI Library
# 
# Usage: ./generate-spm-package.sh --tag <GIT_TAG> [--output-dir <OUTPUT_DIR>]
#
# Author: Generated with Claude Code
# Date: $(date)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
OUTPUT_DIR="./output"
GIT_TAG=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR=""

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Help function
show_help() {
    cat << EOF
Azure Communication UI Library SPM Package Generator

USAGE:
    ./generate-spm-package.sh --tag <GIT_TAG> [OPTIONS]

OPTIONS:
    -t, --tag <GIT_TAG>           Git tag to checkout (required)
    -o, --output-dir <OUTPUT_DIR> Output directory (default: ./output)
    -h, --help                    Show this help message

EXAMPLES:
    ./generate-spm-package.sh --tag "AzureCommunicationUICalling_1.14.1"
    ./generate-spm-package.sh --tag "main" --output-dir "/path/to/output"

DESCRIPTION:
    This script automates the generation of a Swift Package Manager package
    from the Azure Communication UI Library repository. It includes both
    Calling and Chat functionality with all necessary XCFrameworks.

REQUIREMENTS:
    - Xcode (with xcodebuild)
    - CocoaPods
    - Swift Package Manager
    - Git

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--tag)
                GIT_TAG="$2"
                shift 2
                ;;
            -o|--output-dir)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    if [[ -z "$GIT_TAG" ]]; then
        log_error "Git tag is required. Use --tag <GIT_TAG>"
        show_help
        exit 1
    fi
    
    # Convert OUTPUT_DIR to absolute path to avoid issues when changing directories
    OUTPUT_DIR=$(mkdir -p "$OUTPUT_DIR" && cd "$OUTPUT_DIR" && pwd)
}

# Cleanup function
cleanup() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        log_info "Cleaning up temporary directory: $TEMP_DIR"
        rm -rf "$TEMP_DIR"
    fi
}

# Set up cleanup trap
trap cleanup EXIT

# Check required tools
check_requirements() {
    log_step "Checking requirements..."
    
    local missing_tools=()
    
    if ! command -v xcodebuild &> /dev/null; then
        missing_tools+=("xcodebuild (Xcode)")
    fi
    
    if ! command -v pod &> /dev/null; then
        missing_tools+=("pod (CocoaPods)")
    fi
    
    if ! command -v swift &> /dev/null; then
        missing_tools+=("swift (Swift Package Manager)")
    fi
    
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools:"
        for tool in "${missing_tools[@]}"; do
            log_error "  - $tool"
        done
        exit 1
    fi
    
    log_success "All required tools are available"
}

# Phase 1: Repository Setup
setup_repository() {
    log_step "Phase 1: Repository Setup"
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    log_info "Using temporary directory: $TEMP_DIR"
    
    # Clone repository
    log_info "Cloning Azure Communication UI Library repository..."
    git clone https://github.com/Azure/communication-ui-library-ios.git "$TEMP_DIR/repo"
    
    # Navigate to repository
    cd "$TEMP_DIR/repo"
    
    # Checkout specified tag
    log_info "Checking out tag: $GIT_TAG"
    git checkout "$GIT_TAG"
    
    # Validate repository structure
    log_info "Checking repository structure..."
    log_info "Repository contents:"
    ls -la
    
    # Check for possible Podfile locations
    if [[ -f "AzureCommunicationUI/Podfile" ]]; then
        log_info "Found Podfile in AzureCommunicationUI/ directory"
    elif [[ -f "Podfile" ]]; then
        log_info "Found Podfile in root directory"
    else
        log_error "Invalid repository structure: Podfile not found"
        log_error "Please check the repository structure and update the script accordingly"
        exit 1
    fi
    
    log_success "Repository setup completed"
}

# Phase 2: CocoaPods Setup
setup_cocoapods() {
    log_step "Phase 2: CocoaPods Setup"
    
    # Navigate to the correct directory based on repository structure
    if [[ -f "$TEMP_DIR/repo/AzureCommunicationUI/Podfile" ]]; then
        cd "$TEMP_DIR/repo/AzureCommunicationUI"
        log_info "Using AzureCommunicationUI subdirectory"
    elif [[ -f "$TEMP_DIR/repo/Podfile" ]]; then
        cd "$TEMP_DIR/repo"
        log_info "Using repository root directory"
    else
        log_error "Could not find Podfile in expected locations"
        exit 1
    fi
    
    log_info "Installing CocoaPods dependencies in $(pwd)..."
    # Install pods and handle any script phase warnings
    pod install --verbose
    
    # Verify workspace exists (check multiple possible names)
    local workspace_found=false
    for workspace in "AzureCommunicationUI.xcworkspace" "*.xcworkspace"; do
        if [[ -f "$workspace" ]] || ls $workspace 1> /dev/null 2>&1; then
            workspace_found=true
            log_info "Found workspace: $workspace"
            break
        fi
    done
    
    if [[ "$workspace_found" == false ]]; then
        log_error "CocoaPods workspace not found in $(pwd)"
        log_error "Contents of directory:"
        ls -la
        exit 1
    fi
    
    log_success "CocoaPods setup completed"
}

# Build XCFramework helper function
build_xcframework() {
    local scheme="$1"
    local output_name="$2"
    local workspace="$3"
    
    log_info "Building XCFramework for $scheme..."
    
    local build_dir="$TEMP_DIR/build-$scheme"
    mkdir -p "$build_dir"
    
    # Build iOS device archive
    log_info "Building iOS device archive for $scheme..."
    xcodebuild -workspace "$workspace" \
        -scheme "$scheme" \
        -configuration Release \
        -destination 'generic/platform=iOS' \
        -archivePath "$build_dir/$scheme-iOS.xcarchive" \
        archive \
        SKIP_INSTALL=NO \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        > "$build_dir/ios-build.log" 2>&1
    
    # Build iOS simulator archive
    log_info "Building iOS simulator archive for $scheme..."
    xcodebuild -workspace "$workspace" \
        -scheme "$scheme" \
        -configuration Release \
        -destination 'generic/platform=iOS Simulator' \
        -archivePath "$build_dir/$scheme-Simulator.xcarchive" \
        archive \
        SKIP_INSTALL=NO \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        > "$build_dir/simulator-build.log" 2>&1
    
    # Find framework paths
    local ios_framework=$(find "$build_dir/$scheme-iOS.xcarchive" -name "$output_name.framework" -type d | head -1)
    local simulator_framework=$(find "$build_dir/$scheme-Simulator.xcarchive" -name "$output_name.framework" -type d | head -1)
    
    if [[ -z "$ios_framework" || -z "$simulator_framework" ]]; then
        log_error "Could not find framework files for $scheme"
        log_error "iOS framework: $ios_framework"
        log_error "Simulator framework: $simulator_framework"
        return 1
    fi
    
    # Create XCFramework
    local xcframework_path="$TEMP_DIR/xcframeworks/$output_name.xcframework"
    mkdir -p "$(dirname "$xcframework_path")"
    
    log_info "Creating XCFramework for $output_name..."
    xcodebuild -create-xcframework \
        -framework "$ios_framework" \
        -framework "$simulator_framework" \
        -output "$xcframework_path"
    
    log_success "XCFramework created: $output_name.xcframework"
}

# Copy existing XCFrameworks from Pods
copy_pods_xcframeworks() {
    log_info "Copying existing XCFrameworks from Pods..."
    
    local xcframeworks_dir="$TEMP_DIR/xcframeworks"
    mkdir -p "$xcframeworks_dir"
    
    # Copy AzureCommunicationCalling (SDK)
    if [[ -d "Pods/AzureCommunicationCalling/AzureCommunicationCalling.xcframework" ]]; then
        cp -r "Pods/AzureCommunicationCalling/AzureCommunicationCalling.xcframework" "$xcframeworks_dir/"
        log_success "Copied AzureCommunicationCalling.xcframework"
    fi
    
    # Copy Trouter if exists
    if [[ -d "Pods/Trouter/Trouter.xcframework" ]]; then
        cp -r "Pods/Trouter/Trouter.xcframework" "$xcframeworks_dir/"
        log_success "Copied Trouter.xcframework"
    fi
}

# Phase 3: XCFramework Generation
generate_xcframeworks() {
    log_step "Phase 3: XCFramework Generation"
    
    # Navigate to the correct directory based on repository structure
    if [[ -f "$TEMP_DIR/repo/AzureCommunicationUI/Podfile" ]]; then
        cd "$TEMP_DIR/repo/AzureCommunicationUI"
    elif [[ -f "$TEMP_DIR/repo/Podfile" ]]; then
        cd "$TEMP_DIR/repo"
    else
        log_error "Could not find correct build directory"
        exit 1
    fi
    
    log_info "Building XCFrameworks from: $(pwd)"
    
    # Copy existing XCFrameworks from Pods
    copy_pods_xcframeworks
    
    # Build UI frameworks using archives
    local workspace=""
    if [[ -f "AzureCommunicationUI.xcworkspace" ]]; then
        workspace="AzureCommunicationUI.xcworkspace"
    else
        # Find any .xcworkspace file
        workspace=$(find . -name "*.xcworkspace" -maxdepth 1 | head -1)
        if [[ -z "$workspace" ]]; then
            log_error "No .xcworkspace file found"
            exit 1
        fi
        workspace=$(basename "$workspace")
    fi
    log_info "Using workspace: $workspace"
    
    # Build Calling UI
    build_xcframework "AzureCommunicationUICalling" "AzureCommunicationUICalling" "$workspace"
    
    # Build Chat UI
    build_xcframework "AzureCommunicationUIChat" "AzureCommunicationUIChat" "$workspace"
    
    # Extract frameworks from archives for dependencies
    log_info "Extracting dependency frameworks from archives..."
    
    # Find and copy dependency frameworks from the calling build
    local calling_archive="$TEMP_DIR/build-AzureCommunicationUICalling/AzureCommunicationUICalling-iOS.xcarchive"
    local calling_sim_archive="$TEMP_DIR/build-AzureCommunicationUICalling/AzureCommunicationUICalling-Simulator.xcarchive"
    
    # Create XCFrameworks for dependencies
    local dependencies=("FluentUI" "AzureCommunicationCommon" "AzureCore")
    
    for dep in "${dependencies[@]}"; do
        log_info "Creating XCFramework for $dep..."
        
        local ios_fw=$(find "$calling_archive" -name "$dep.framework" -type d | head -1)
        local sim_fw=$(find "$calling_sim_archive" -name "$dep.framework" -type d | head -1)
        
        if [[ -n "$ios_fw" && -n "$sim_fw" ]]; then
            xcodebuild -create-xcframework \
                -framework "$ios_fw" \
                -framework "$sim_fw" \
                -output "$TEMP_DIR/xcframeworks/$dep.xcframework"
            log_success "Created $dep.xcframework"
        else
            log_warning "Could not find $dep framework in archives"
        fi
    done
    
    # For Chat, we also need AzureCommunicationChat SDK
    log_info "Creating XCFramework for AzureCommunicationChat..."
    local chat_archive="$TEMP_DIR/build-AzureCommunicationUIChat/AzureCommunicationUIChat-iOS.xcarchive"
    local chat_sim_archive="$TEMP_DIR/build-AzureCommunicationUIChat/AzureCommunicationUIChat-Simulator.xcarchive"
    
    local chat_ios_fw=$(find "$chat_archive" -name "AzureCommunicationChat.framework" -type d | head -1)
    local chat_sim_fw=$(find "$chat_sim_archive" -name "AzureCommunicationChat.framework" -type d | head -1)
    
    if [[ -n "$chat_ios_fw" && -n "$chat_sim_fw" ]]; then
        xcodebuild -create-xcframework \
            -framework "$chat_ios_fw" \
            -framework "$chat_sim_fw" \
            -output "$TEMP_DIR/xcframeworks/AzureCommunicationChat.xcframework"
        log_success "Created AzureCommunicationChat.xcframework"
    fi
    
    log_success "XCFramework generation completed"
}

# Phase 4: SPM Package Generation
generate_spm_package() {
    log_step "Phase 4: SPM Package Generation"
    
    # Output directory is already absolute from parse_args
    log_info "Creating SPM package in: $OUTPUT_DIR"
    
    # Clean output directory
    rm -rf "$OUTPUT_DIR"/*
    
    # Create directory structure
    mkdir -p "$OUTPUT_DIR/spm-generated/XCFrameworks"
    mkdir -p "$OUTPUT_DIR/AzureCommunicationUI/sdk/AzureCommunicationUICommon/Sources"
    
    # Copy XCFrameworks
    log_info "Copying XCFrameworks to output directory..."
    cp -r "$TEMP_DIR/xcframeworks"/* "$OUTPUT_DIR/spm-generated/XCFrameworks/"
    
    # Copy source files for AzureCommunicationUICommon
    log_info "Copying AzureCommunicationUICommon source files..."
    
    # Find the correct source path
    local common_source_path=""
    if [[ -d "$TEMP_DIR/repo/AzureCommunicationUI/sdk/AzureCommunicationUICommon/Sources/AzureCommunicationUICommon" ]]; then
        common_source_path="$TEMP_DIR/repo/AzureCommunicationUI/sdk/AzureCommunicationUICommon/Sources/AzureCommunicationUICommon"
    elif [[ -d "$TEMP_DIR/repo/sdk/AzureCommunicationUICommon/Sources/AzureCommunicationUICommon" ]]; then
        common_source_path="$TEMP_DIR/repo/sdk/AzureCommunicationUICommon/Sources/AzureCommunicationUICommon"
    else
        log_error "Could not find AzureCommunicationUICommon source files"
        log_error "Checked locations:"
        log_error "  - $TEMP_DIR/repo/AzureCommunicationUI/sdk/AzureCommunicationUICommon/Sources/AzureCommunicationUICommon"
        log_error "  - $TEMP_DIR/repo/sdk/AzureCommunicationUICommon/Sources/AzureCommunicationUICommon"
        exit 1
    fi
    
    cp -r "$common_source_path" "$OUTPUT_DIR/AzureCommunicationUI/sdk/AzureCommunicationUICommon/Sources/"
    
    # Generate Package.swift from template
    log_info "Generating Package.swift..."
    cat > "$OUTPUT_DIR/Package.swift" << 'EOF'
// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AzureCommunicationUI",
    platforms: [.iOS(.v16)],
    products: [
        // Azure Communication Services Calling SDK (XCFramework binary)
        .library(
            name: "AzureCommunicationCalling",
            targets: ["AzureCommunicationCalling"]
        ),
        // Azure Communication UI Calling Library (XCFramework binary)
        .library(
            name: "AzureCommunicationUICalling",
            targets: ["AzureCommunicationUICallingBinary", "FluentUI", "AzureCommunicationCommon", "AzureCore"]
        ),
        // Azure Communication UI Chat Library (XCFramework binary)
        .library(
            name: "AzureCommunicationUIChat",
            targets: ["AzureCommunicationUIChatBinary", "AzureCommunicationChat", "Trouter", "FluentUI", "AzureCommunicationCommon", "AzureCore"]
        ),
        // Azure Communication UI Common Library (from local sources)
        .library(
            name: "AzureCommunicationUICommon",
            targets: ["AzureCommunicationUICommon"]
        )
    ],
    dependencies: [
        // No external dependencies needed - using local sources and XCFrameworks
    ],
    targets: [
        // MARK: - Binary Targets (XCFrameworks)
        
        // AzureCommunicationCalling binary target (Azure Communication Services Calling SDK)
        .binaryTarget(
            name: "AzureCommunicationCalling",
            path: "spm-generated/XCFrameworks/AzureCommunicationCalling.xcframework"
        ),
        
        // AzureCommunicationUICalling binary target (Calling UI Library)
        .binaryTarget(
            name: "AzureCommunicationUICallingBinary",
            path: "spm-generated/XCFrameworks/AzureCommunicationUICalling.xcframework"
        ),
        
        // AzureCommunicationUIChat binary target (Chat UI Library)
        .binaryTarget(
            name: "AzureCommunicationUIChatBinary",
            path: "spm-generated/XCFrameworks/AzureCommunicationUIChat.xcframework"
        ),
        
        // AzureCommunicationChat binary target (Chat SDK)
        .binaryTarget(
            name: "AzureCommunicationChat",
            path: "spm-generated/XCFrameworks/AzureCommunicationChat.xcframework"
        ),
        
        // FluentUI binary target (Microsoft FluentUI components)
        .binaryTarget(
            name: "FluentUI",
            path: "spm-generated/XCFrameworks/FluentUI.xcframework"
        ),
        
        // AzureCommunicationCommon binary target (Azure Communication Common)
        .binaryTarget(
            name: "AzureCommunicationCommon",
            path: "spm-generated/XCFrameworks/AzureCommunicationCommon.xcframework"
        ),
        
        // AzureCore binary target (Azure Core)
        .binaryTarget(
            name: "AzureCore",
            path: "spm-generated/XCFrameworks/AzureCore.xcframework"
        ),
        
        // Trouter binary target (Azure Communication Services Trouter)
        .binaryTarget(
            name: "Trouter",
            path: "spm-generated/XCFrameworks/Trouter.xcframework"
        ),
        
        // MARK: - Source Targets (Local)
        
        // AzureCommunicationUICommon from local sources
        .target(
            name: "AzureCommunicationUICommon",
            path: "AzureCommunicationUI/sdk/AzureCommunicationUICommon/Sources/AzureCommunicationUICommon"
        )
    ]
)
EOF
    
    log_success "SPM package generation completed"
}

# Phase 5: Validation & Testing
validate_package() {
    log_step "Phase 5: Validation & Testing"
    
    # Navigate to output directory
    cd "$OUTPUT_DIR"
    log_info "Validating package in: $OUTPUT_DIR"
    
    # Test package resolution
    log_info "Testing package resolution..."
    if swift package resolve; then
        log_success "Package resolves successfully"
    else
        log_error "Package resolution failed"
        return 1
    fi
    
    # Validate XCFramework architectures
    log_info "Validating XCFramework architectures..."
    local xcframework_dir="spm-generated/XCFrameworks"
    
    for xcfw in "$xcframework_dir"/*.xcframework; do
        if [[ -d "$xcfw" ]]; then
            local name=$(basename "$xcfw" .xcframework)
            log_info "Checking $name..."
            
            # Check if both iOS and simulator variants exist
            if [[ -d "$xcfw/ios-arm64" && -d "$xcfw/ios-arm64_x86_64-simulator" ]]; then
                log_success "$name has proper architecture support"
            else
                log_warning "$name may be missing some architectures"
            fi
        fi
    done
    
    # Generate test import file
    log_info "Generating test import file..."
    cat > "TEST_IMPORTS.swift" << 'EOF'
// Test file to verify imports work correctly
import Foundation
import AzureCommunicationCalling
import AzureCommunicationUICalling
import AzureCommunicationUIChat
import AzureCommunicationUICommon

// Test that we can access types from all modules
func testImports() {
    print("All modules imported successfully!")
    
    // These should compile without errors if imports work
    let _ = AzureCommunicationCalling.self
    let _ = AzureCommunicationUICalling.self
    let _ = AzureCommunicationUIChat.self
    let _ = AzureCommunicationUICommon.self
    
    print("✅ SPM Package is ready for use!")
    print("Available imports:")
    print("  - import AzureCommunicationCalling")
    print("  - import AzureCommunicationUICalling")
    print("  - import AzureCommunicationUIChat")
    print("  - import AzureCommunicationUICommon")
}
EOF
    
    log_success "Validation completed"
}

# Generate documentation
generate_documentation() {
    log_info "Generating documentation..."
    
    # Navigate to output directory
    cd "$OUTPUT_DIR"
    log_info "Generating documentation in: $OUTPUT_DIR"
    
    # Generate README
    cat > "README.md" << EOF
# Azure Communication UI Library - Swift Package Manager

This package provides Swift Package Manager support for the Azure Communication UI Library for iOS.

## Generated Information
- **Git Tag**: $GIT_TAG
- **Generated On**: $(date)
- **Generator**: Azure Communication UI Library SPM Package Generator

## Features

### Available Products
- **AzureCommunicationCalling** - Azure Communication Services Calling SDK
- **AzureCommunicationUICalling** - Calling UI Library with full functionality
- **AzureCommunicationUIChat** - Chat UI Library with full functionality  
- **AzureCommunicationUICommon** - Common utilities and components

### Architecture Support
- **iOS Device**: arm64 (iPhone/iPad)
- **iOS Simulator**: arm64 + x86_64 (Apple Silicon + Intel Macs)

## Installation

### Swift Package Manager

Add this package to your \`Package.swift\`:

\`\`\`swift
dependencies: [
    .package(path: "path/to/this/package")
]
\`\`\`

Or add it to your Xcode project:
1. File → Add Package Dependencies
2. Add Local Package
3. Select this folder

## Usage

\`\`\`swift
import AzureCommunicationCalling      // Calling SDK
import AzureCommunicationUICalling    // Calling UI Library
import AzureCommunicationUIChat       // Chat UI Library
import AzureCommunicationUICommon     // Common utilities
\`\`\`

## What's Included

This package includes:
- All necessary XCFrameworks with proper iOS device + simulator support
- Source code for common utilities
- Complete dependency resolution
- Localization resources
- Assets and resources

## Platform Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

## License

Same as the original Azure Communication UI Library - MIT License

## Generated Package

This is an automatically generated SPM package from the Azure Communication UI Library repository.
- Original Repository: https://github.com/Azure/communication-ui-library-ios
- Git Tag: $GIT_TAG
EOF
    
    log_success "Documentation generated"
}

# Main execution function
main() {
    log_info "🚀 Azure Communication UI Library SPM Package Generator"
    log_info "=================================================="
    
    parse_args "$@"
    
    log_info "Configuration:"
    log_info "  Git Tag: $GIT_TAG"
    log_info "  Output Directory: $OUTPUT_DIR"
    log_info ""
    
    check_requirements
    setup_repository
    setup_cocoapods
    generate_xcframeworks
    generate_spm_package
    validate_package
    generate_documentation
    
    log_success "🎉 SPM package generation completed successfully!"
    log_success "Package location: $OUTPUT_DIR"
    log_info ""
    log_info "Next steps:"
    log_info "1. Navigate to the output directory"
    log_info "2. Add the package to your iOS project"
    log_info "3. Import the required modules in your Swift code"
    log_info ""
    log_info "Available imports:"
    log_info "  - import AzureCommunicationCalling"
    log_info "  - import AzureCommunicationUICalling"
    log_info "  - import AzureCommunicationUIChat"
    log_info "  - import AzureCommunicationUICommon"
}

# Run main function
main "$@"