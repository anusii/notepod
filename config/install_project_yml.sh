#!/bin/bash
#
# Time-stamp: Friday 2025-12-05 12:34:03 Jess Moore
#
# Install project yaml for platform
#
# Usage: install_project_yml.sh [args...]

function usage() {
    echo "Usage: install_project_yml.sh build_folder"
    echo ""
    echo "Description: Install project yaml for platform."
    echo ""
    echo "Arguments:"
    echo "  build_folder:  Build folder. Ie. ios or macos."
    echo ""
    exit 1 # Exit with a non-zero status to indicate an error
}

if [[ $# -ne 1 || $* == *"help"* || $* == *"-h"* ]]; then
    usage
fi

if [[ $# -eq 1 ]]; then
    BUILD_FOLDER=$1
fi

PROJECT_FILE=project.yml

if [[ "${BUILD_FOLDER}" == "macos" ]];  then

    echo "Installing ${PROJECT_FILE} for ${BUILD_FOLDER}"

cat > ${PROJECT_FILE} << 'EOF'
# Use `bash update_project.sh [platform]` to generate xcode project
# build files from this project.yml
#
# Code signing: to set code sign/no code signing of apps with
# Apple certificates update these build settings in the build flavors (configs):
# CODE_SIGN_STYLE: "Automatic"
# CODE_SIGN_IDENTITY: "-"
# PROVISIONING_PROFILE_SPECIFIER: ""
# Change:
# CODE_SIGN_STYLE to "Manual"
# CODE_SIGN_IDENTITY to signing certificate name
# PROVISIONING_PROFILE_SPECIFIER to provisioning profile name
# And ensure that developer team and entitlements are set, and
# that entitlements file includes developer team
# CODE_SIGN_ENTITLEMENTS: set to correct Runner/*.entitlemnts file
# DEVELOPMENT_TEAM: [developer_team on Apple Developer account]
# Note: On macos, keychain access entitlement is needed to use local
# secure storage and requires app code signing. Local secure storage
# is used by Solid apps for app security key.

name: Runner

# Optional: include configuration in other yaml files
# if project config split over multiple files
# include:
#   - other.yml

options:
  deploymentTarget:
    macOS: "15.1"
  createIntermediateGroups: true

# TODO: add flavor setup here
configs:
  Debug: Debug
  Profile: Profile
  Release: Release

# TODO: add flavor setup here
configFiles:
  Debug: Flutter/Flutter-Debug.xcconfig
  Profile: Flutter/Flutter-Release.xcconfig
  Release: Flutter/Flutter-Release.xcconfig

settings:
  base:
    # TODO: Optionally set to NONE and use APP_NAME to set flavor specific product name
    # Eg. https://github.com/lllttt06/xcodegen_flutter_sample/blob/main/ios/project.yml
    PRODUCT_NAME: "$(TARGET_NAME)" # 'NONE'
    # TODO: Optionally use a different app icon for each
    # flavor in a different app icon subfolder in Runner/assets.xcassets/
    # Eg. https://github.com/lllttt06/xcodegen_flutter_sample/blob/main/ios/project.yml
    ASSETCATALOG_COMPILER_APPICON_NAME: "AppIcon"
    DEVELOPMENT_TEAM: G7843T3SD3 # Togaware Apple Developer Team ID
    SWIFT_VERSION: "5.0"

targets:
  Runner:
    type: application
    platform: macOS
    attributes:
      # TODO: Update when move to manual code signing
      ProvisioningStyle: Automatic
      SystemCapabilities:
        com.apple.Sandbox:
          enabled: 1
    dependencies:
      - sdk: Pods_Runner.framework
        embed: false
        link: true

    sources:
      - path: Runner/
      - path: Runner/MainFlutterWindow.swift
        buildPhase: "sources"
      - path: Runner/AppDelegate.swift
        buildPhase: "sources"
      - path: Flutter/GeneratedPluginRegistrant.swift
        buildPhase: "sources"
      - path: Runner/Assets.xcassets
        buildPhase: "resources"
        type: "folder"

    preBuildScripts:

      # [CP] Check Pods Manifest.lock
      - name: "[CP] Check Pods Manifest.lock"
        inputFiles: [
          "${PODS_PODFILE_DIR_PATH}/Podfile.lock",
          "${PODS_ROOT}/Manifest.lock"
          ]
        outputFiles: [
          "$(DERIVED_FILE_DIR)/Pods-Runner-checkManifestLockResult.txt"
          ]
        script: "diff \"${PODS_PODFILE_DIR_PATH}/Podfile.lock\" \"${PODS_ROOT}/Manifest.lock\" > /dev/null\nif [ $? != 0 ] ; then\n    # print error to STDERR\n    echo \"error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation.\" >&2\n    exit 1\nfi\n# This output is used by Xcode 'outputs' to avoid re-running this script phase.\necho \"SUCCESS\" > \"${SCRIPT_OUTPUT_FILE_0}\"\n"

      # Build script
      - name: "ShellScript - build"
        basedOnDependencyAnalysis: false
        script: "\"$FLUTTER_ROOT\"/packages/flutter_tools/bin/macos_assemble.sh build\n"

    postBuildScripts:

      # Embed script
      - name: "ShellScript - embed"
        basedOnDependencyAnalysis: false
        script: "echo \"$PRODUCT_NAME.app\" > \"$PROJECT_DIR\"/Flutter/ephemeral/.app_filename && \"$FLUTTER_ROOT\"/packages/flutter_tools/bin/macos_assemble.sh embed\n"

    settings:
      base:
        # TODO: set app bundle ID
        PRODUCT_BUNDLE_IDENTIFIER: com.togaware.test # App Bundle ID from Apple Developer account

        ALWAYS_SEARCH_USER_PATHS: "NO"
        ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS: "YES"
        CLANG_ANALYZER_NONNULL: "YES"
        CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION: "YES_AGGRESSIVE"
        CLANG_CXX_LANGUAGE_STANDARD: "gnu++14"
        CLANG_CXX_LIBRARY: "libc++"
        CLANG_ENABLE_MODULES: "YES"
        CLANG_ENABLE_OBJC_ARC: "YES"
        CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING: "YES"
        CLANG_WARN_BOOL_CONVERSION: "YES"
        CLANG_WARN_CONSTANT_CONVERSION: "YES"
        CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS: "YES"
        CLANG_WARN_DIRECT_OBJC_ISA_USAGE: "YES_ERROR"
        CLANG_WARN_DOCUMENTATION_COMMENTS: "YES"
        CLANG_WARN_EMPTY_BODY: "YES"
        CLANG_WARN_ENUM_CONVERSION: "YES"
        CLANG_WARN_INFINITE_RECURSION: "YES"
        CLANG_WARN_INT_CONVERSION: "YES"
        CLANG_WARN_NON_LITERAL_NULL_CONVERSION: "YES"
        CLANG_WARN_OBJC_LITERAL_CONVERSION: "YES"
        CLANG_WARN_OBJC_ROOT_CLASS: "YES_ERROR"
        CLANG_WARN_RANGE_LOOP_ANALYSIS: "YES"
        CLANG_WARN_SUSPICIOUS_MOVE: "YES"
        COPY_PHASE_STRIP: "NO"
        COMBINE_HIDPI_IMAGES: "YES"
        DEAD_CODE_STRIPPING: "YES"
        ENABLE_STRICT_OBJC_MSGSEND: "YES"
        ENABLE_USER_SCRIPT_SANDBOXING: "NO"
        GCC_C_LANGUAGE_STANDARD: "gnu11"
        GCC_NO_COMMON_BLOCKS: "YES"
        GCC_WARN_64_TO_32_BIT_CONVERSION: "YES"
        GCC_WARN_ABOUT_RETURN_TYPE: "YES_ERROR"
        GCC_WARN_UNINITIALIZED_AUTOS: "YES_AGGRESSIVE"
        GCC_WARN_UNUSED_FUNCTION: "YES"
        GCC_WARN_UNUSED_VARIABLE: "YES"
        INFOPLIST_FILE: "Runner/Info.plist"
        LD_RUNPATH_SEARCH_PATHS: [
            "$(inherited)",
            "@executable_path/../Frameworks"
          ]
        SDKROOT: "macosx"

      # TODO: add flavor setup here
      configs:

        Debug:
          CODE_SIGN_STYLE: "Automatic"
          CODE_SIGN_IDENTITY: "-"
          CODE_SIGN_ENTITLEMENTS: "Runner/DebugProfile.entitlements"
          PROVISIONING_PROFILE_SPECIFIER: ""

          DEBUG_INFORMATION_FORMAT: "dwarf"
          ENABLE_TESTABILITY: "YES"
          GCC_DYNAMIC_NO_PIC: "NO"
          GCC_OPTIMIZATION_LEVEL: "0"
          GCC_PREPROCESSOR_DEFINITIONS: [
            "DEBUG=1",
            "$(inherited)"
          ]
          MTL_ENABLE_DEBUG_INFO: "YES"
          ONLY_ACTIVE_ARCH: "YES"
          SWIFT_ACTIVE_COMPILATION_CONDITIONS: "DEBUG"
          SWIFT_OPTIMIZATION_LEVEL: "-Onone"

        Release:
          CODE_SIGN_STYLE: "Automatic"
          CODE_SIGN_IDENTITY: "-"
          CODE_SIGN_ENTITLEMENTS: "Runner/Release.entitlements"
          PROVISIONING_PROFILE_SPECIFIER: ""

          DEBUG_INFORMATION_FORMAT: "dwarf-with-dsym"
          ENABLE_NS_ASSERTIONS: "NO"
          MTL_ENABLE_DEBUG_INFO: "NO"
          SWIFT_COMPILATION_MODE: "wholemodule"
          SWIFT_OPTIMIZATION_LEVEL: "-O"


        Profile:
          CODE_SIGN_STYLE: "Automatic"
          CODE_SIGN_IDENTITY: "-"
          CODE_SIGN_ENTITLEMENTS: "Runner/DebugProfile.entitlements"
          PROVISIONING_PROFILE_SPECIFIER: ""

          DEBUG_INFORMATION_FORMAT: "dwarf-with-dsym"
          ENABLE_NS_ASSERTIONS: "NO"
          MTL_ENABLE_DEBUG_INFO: "NO"
          SWIFT_COMPILATION_MODE: "wholemodule"
          SWIFT_OPTIMIZATION_LEVEL: "-O"


  RunnerTests:
    type: bundle.unit-test
    platform: macOS

    sources:
      - path: RunnerTests/
      - path: RunnerTests/RunnerTests.swift
        buildPhase: "sources"

    dependencies:
      - target: Runner

    preBuildScripts:
      # [CP] Check Pods Manifest.lock
      - name: "[CP] Check Pods Manifest.lock"
        inputFiles: [
          "${PODS_PODFILE_DIR_PATH}/Podfile.lock",
          "${PODS_ROOT}/Manifest.lock"
          ]
        outputFiles: [
          "$(DERIVED_FILE_DIR)/Pods-Runner-checkManifestLockResult.txt"
          ]
        script: "diff \"${PODS_PODFILE_DIR_PATH}/Podfile.lock\" \"${PODS_ROOT}/Manifest.lock\" > /dev/null\nif [ $? != 0 ] ; then\n    # print error to STDERR\n    echo \"error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation.\" >&2\n    exit 1\nfi\n# This output is used by Xcode 'outputs' to avoid re-running this script phase.\necho \"SUCCESS\" > \"${SCRIPT_OUTPUT_FILE_0}\"\n"

    settings:
      base:
        BUNDLE_LOADER: "$(TEST_HOST)"
        CURRENT_PROJECT_VERSION: "1"
        GENERATE_INFOPLIST_FILE: "YES"
        MARKETING_VERSION: "1.0"
        # TODO: set app bundle ID
        PRODUCT_BUNDLE_IDENTIFIER: "com.togaware.test.RunnerTests"
        TEST_HOST: "$(BUILT_PRODUCTS_DIR)/test.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/test"

      # Add any config specific build settings for RunnerTests go here
      # configs:

      #   Debug:

      #   Release:

      #   Profile:

# TODO: add flavor setup here
schemes:
  Runner:
    build:
      targets:
        Runner: all
    run:
      config: Debug
    test:
      config: Debug
    profile:
      config: Profile
    analyze:
      config: Debug
    archive:
      config: Release
EOF

elif [[ "${BUILD_FOLDER}" == "ios" ]];  then

    echo "Installing ${PROJECT_FILE} for ${BUILD_FOLDER}"

cat > ${PROJECT_FILE} << 'EOFF'
# Use `bash update_project.sh [platform]` to generate xcode project
# build files from this project.yml
#
# Code signing: to set code sign/no code signing of apps with
# Apple certificates update these build settings in the build flavors (configs):
# CODE_SIGN_STYLE: "Automatic"
# CODE_SIGN_IDENTITY: "-"
# PROVISIONING_PROFILE_SPECIFIER: ""
# Change:
# CODE_SIGN_STYLE to "Manual"
# CODE_SIGN_IDENTITY to signing certificate name
# PROVISIONING_PROFILE_SPECIFIER to provisioning profile name
# And ensure that developer team and entitlements are set, and
# that entitlements file includes developer team
# CODE_SIGN_ENTITLEMENTS: set to correct Runner/*.entitlemnts file
# DEVELOPMENT_TEAM: [developer_team on Apple Developer account]
# Note: On macos, keychain access entitlement is needed to use local
# secure storage and requires app code signing. Local secure storage
# is used by Solid apps for app security key. Not sure yet how its
# different on ios

name: Runner

options:
  xcodeVersion: '15.4.0'
  developmentLanguage: ja
  deploymentTarget:
    iOS: 16.0

# Optional: include configuration in other yaml files
# if project config split over multiple files
# include:
#   - other.yml

# TODO: add flavor setup here
configs:
  Debug: Debug
  Profile: Profile
  Release: Release

# TODO: add flavor setup here
configFiles:
  Debug: Flutter/Debug.xcconfig
  Profile: Flutter/Release.xcconfig
  Release: Flutter/Release.xcconfig

settings:
  base:
    # TODO: Optionally set to NONE and use APP_NAME to set flavor specific product name
    # Eg. https://github.com/lllttt06/xcodegen_flutter_sample/blob/main/ios/project.yml
    PRODUCT_NAME: "$(TARGET_NAME)" # 'NONE'
    # TODO: Optionally use a different app icon for each
    # flavor in a different app icon subfolder in Runner/assets.xcassets/
    # Eg. https://github.com/lllttt06/xcodegen_flutter_sample/blob/main/ios/project.yml
    ASSETCATALOG_COMPILER_APPICON_NAME: "AppIcon"
    DEVELOPMENT_TEAM: G7843T3SD3 # Togaware Apple Developer Team ID
    SWIFT_VERSION: "5.0"

targets:
  Runner:
    type: application
    platform: iOS
    dependencies:
      - sdk: Pods_Runner.framework
        embed: false
        link: true

    sources:
      - Flutter/AppFrameworkInfo.plist
      - Flutter/Generated.xcconfig
      - Flutter/Debug.xcconfig
      - Flutter/Release.xcconfig
      - path: Runner/

    preBuildScripts:

      # [CP] Check Pods Manifest.lock
      - name: '[CP] Check Pods Manifest.lock'
        inputFiles:
          - ${PODS_PODFILE_DIR_PATH}/Podfile.lock
          - ${PODS_ROOT}/Manifest.lock
        outputFiles:
          - $(DERIVED_FILE_DIR)/Pods-Runner-checkManifestLockResult.txt
        script: "diff \"${PODS_PODFILE_DIR_PATH}/Podfile.lock\" \"${PODS_ROOT}/Manifest.lock\" > /dev/null\nif [ $? != 0 ] ; then\n    # print error to STDERR\n    echo \"error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation.\" >&2\n    exit 1\nfi\n# This output is used by Xcode 'outputs' to avoid re-running this script phase.\necho \"SUCCESS\" > \"${SCRIPT_OUTPUT_FILE_0}\"\n"

      # Build script
      - name: "ShellScript - build"
        basedOnDependencyAnalysis: false
        script: "\"$FLUTTER_ROOT\"/packages/flutter_tools/bin/xcode_backend.sh build\n"

    postBuildScripts:

      # Embed and thin script
      - name: "ShellScript - thin Binary"
        basedOnDependencyAnalysis: false
        inputFiles:
          - ${TARGET_BUILD_DIR}/${INFOPLIST_PATH}
        script: "\"$FLUTTER_ROOT\"/packages/flutter_tools/bin/xcode_backend.sh embed_and_thin\n"

    settings:
      base:
        # TODO: set app bundle ID
        PRODUCT_BUNDLE_IDENTIFIER: com.togaware.test # App Bundle ID from Apple Developer account

        ALWAYS_SEARCH_USER_PATHS: NO
        ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS: YES
        ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS: NO
        CLANG_ANALYZER_NONNULL: YES
        CLANG_CXX_LANGUAGE_STANDARD: 'gnu++0x'
        CLANG_CXX_LIBRARY: 'libc++'
        CLANG_ENABLE_MODULES: YES
        CLANG_ENABLE_OBJC_ARC: YES
        CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING: YES
        CLANG_WARN_BOOL_CONVERSION: YES
        CLANG_WARN_COMMA: YES
        CLANG_WARN_CONSTANT_CONVERSION: YES
        CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS: YES
        CLANG_WARN_DIRECT_OBJC_ISA_USAGE: YES_ERROR
        CLANG_WARN_EMPTY_BODY: YES
        CLANG_WARN_ENUM_CONVERSION: YES
        CLANG_WARN_INFINITE_RECURSION: YES
        CLANG_WARN_INT_CONVERSION: YES
        CLANG_WARN_NON_LITERAL_NULL_CONVERSION: YES
        CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF: YES
        CLANG_WARN_OBJC_LITERAL_CONVERSION: YES
        CLANG_WARN_OBJC_ROOT_CLASS: YES_ERROR
        CLANG_WARN_RANGE_LOOP_ANALYSIS: YES
        CLANG_WARN_STRICT_PROTOTYPES: YES
        CLANG_WARN_SUSPICIOUS_MOVE: YES
        CLANG_WARN_UNREACHABLE_CODE: YES
        CLANG_WARN__DUPLICATE_METHOD_MATCH: YES
        COPY_PHASE_STRIP: NO
        CURRENT_PROJECT_VERSION: '$(FLUTTER_BUILD_NUMBER)'
        ENABLE_BITCODE: NO
        ENABLE_STRICT_OBJC_MSGSEND: YES
        ENABLE_USER_SCRIPT_SANDBOXING: NO
        GCC_C_LANGUAGE_STANDARD: gnu99
        GCC_NO_COMMON_BLOCKS: YES
        GCC_WARN_64_TO_32_BIT_CONVERSION: YES
        GCC_WARN_ABOUT_RETURN_TYPE: YES_ERROR
        GCC_WARN_UNDECLARED_SELECTOR: YES
        GCC_WARN_UNINITIALIZED_AUTOS: YES_AGGRESSIVE
        GCC_WARN_UNUSED_FUNCTION: YES
        GCC_WARN_UNUSED_VARIABLE: YES
        INFOPLIST_FILE: Runner/Info.plist
        SDKROOT: iphoneos
        SWIFT_OBJC_BRIDGING_HEADER: 'Runner/Runner-Bridging-Header.h'
        TARGETED_DEVICE_FAMILY: '1,2' # 1=iPhone, 2=iPad
        VERSIONING_SYSTEM: 'apple-generic'

      # TODO: add flavor setup here
      configs:

        Debug:
          'CODE_SIGN_IDENTITY[sdk=iphoneos*]': 'iPhone Developer'
          # CODE_SIGN_STYLE: "Automatic"
          # CODE_SIGN_IDENTITY: "-"
          # CODE_SIGN_ENTITLEMENTS: "Runner/DebugProfile.entitlements"
          # PROVISIONING_PROFILE_SPECIFIER: ""
          DEBUG_INFORMATION_FORMAT: dwarf
          ENABLE_TESTABILITY: YES
          GCC_DYNAMIC_NO_PIC: NO
          GCC_OPTIMIZATION_LEVEL: 0
          GCC_PREPROCESSOR_DEFINITIONS: [
              DEBUG=1,
              $(inherited)
          ]
          MTL_ENABLE_DEBUG_INFO: YES
          ONLY_ACTIVE_ARCH: YES
          SWIFT_OPTIMIZATION_LEVEL: '-Onone'

        Release:
          'CODE_SIGN_IDENTITY[sdk=iphoneos*]': 'iPhone Developer'
          # CODE_SIGN_STYLE: "Automatic"
          # CODE_SIGN_IDENTITY: "-"
          # CODE_SIGN_ENTITLEMENTS: "Runner/DebugProfile.entitlements"
          # PROVISIONING_PROFILE_SPECIFIER: ""
          DEBUG_INFORMATION_FORMAT: dwarf-with-dsym
          ENABLE_NS_ASSERTIONS: NO
          MTL_ENABLE_DEBUG_INFO: NO
          SUPPORTED_PLATFORMS: iphoneos
          SWIFT_COMPILATION_MODE: wholemodule
          SWIFT_OPTIMIZATION_LEVEL: '-O'
          VALIDATE_PRODUCT: YES

        Profile:
          'CODE_SIGN_IDENTITY[sdk=iphoneos*]': 'iPhone Developer'
          # CODE_SIGN_STYLE: "Automatic"
          # CODE_SIGN_IDENTITY: "-"
          # CODE_SIGN_ENTITLEMENTS: "Runner/DebugProfile.entitlements"
          # PROVISIONING_PROFILE_SPECIFIER: ""
          ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS: YES
          DEBUG_INFORMATION_FORMAT: "dwarf-with-dsym"
          ENABLE_NS_ASSERTIONS: NO
          MTL_ENABLE_DEBUG_INFO: NO
          SUPPORTED_PLATFORMS: iphoneos
          VALIDATE_PRODUCT: YES


# TODO: these macos RunnerTest settings need adapting to ios
  RunnerTests:
    type: bundle.unit-test
    platform: iOS

    sources:
      - path: RunnerTests/
      - path: RunnerTests/RunnerTests.swift
        buildPhase: "sources"

    dependencies:
      - target: Runner

    preBuildScripts:
      # [CP] Check Pods Manifest.lock
      - name: "[CP] Check Pods Manifest.lock"
        inputFiles: [
          "${PODS_PODFILE_DIR_PATH}/Podfile.lock",
          "${PODS_ROOT}/Manifest.lock"
          ]
        outputFiles: [
          "$(DERIVED_FILE_DIR)/Pods-Runner-checkManifestLockResult.txt"
          ]
        script: "diff \"${PODS_PODFILE_DIR_PATH}/Podfile.lock\" \"${PODS_ROOT}/Manifest.lock\" > /dev/null\nif [ $? != 0 ] ; then\n    # print error to STDERR\n    echo \"error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation.\" >&2\n    exit 1\nfi\n# This output is used by Xcode 'outputs' to avoid re-running this script phase.\necho \"SUCCESS\" > \"${SCRIPT_OUTPUT_FILE_0}\"\n"

    settings:
      base:
        BUNDLE_LOADER: "$(TEST_HOST)"
        CURRENT_PROJECT_VERSION: "1"
        GENERATE_INFOPLIST_FILE: "YES"
        MARKETING_VERSION: "1.0"
        PRODUCT_BUNDLE_IDENTIFIER: "com.togaware.test.RunnerTests"
        TEST_HOST: "$(BUILT_PRODUCTS_DIR)/test.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/test"

      # Add any config specific build settings for RunnerTests go here
      # configs:

      #   Debug:

      #   Release:

      #   Profile:

# TODO: add flavor setup here
schemes:
  Runner:
    build:
      targets:
        Runner: all
    run:
      config: Debug
    test:
      config: Debug
    profile:
      config: Profile
    analyze:
      config: Debug
    archive:
      config: Release
EOFF

else

    echo "Must be macos or ios."
    exit 1

fi

echo "Done - install project.yml."
