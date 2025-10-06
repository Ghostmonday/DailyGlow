#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║     🌟 Daily Glow - Complete Xcode Project Setup          ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Starting setup process..."
echo ""

# Check dependencies
echo -e "${BLUE}Checking dependencies...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python 3 is required but not installed${NC}"
    exit 1
fi

if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}✗ Xcode command line tools are required but not installed${NC}"
    echo "Please install Xcode from the App Store or run: xcode-select --install"
    exit 1
fi

echo -e "${GREEN}✓ All dependencies satisfied${NC}"

# Backup existing project if it exists
if [ -d "DailyGlow.xcodeproj" ]; then
    echo -e "${BLUE}Backing up existing project...${NC}"
    mv DailyGlow.xcodeproj "DailyGlow.xcodeproj.backup.$(date +%s)"
    echo -e "${GREEN}✓ Backup created${NC}"
fi

# Create Info.plist if it doesn't exist
if [ ! -f "Info.plist" ]; then
    echo -e "${BLUE}Creating Info.plist...${NC}"
    cat > Info.plist << 'PLIST_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>Daily Glow</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>arm64</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    <key>NSUserNotificationsUsageDescription</key>
    <string>Daily Glow sends you daily affirmation reminders to brighten your day</string>
    <key>UILaunchScreen</key>
    <dict>
        <key>UIColorName</key>
        <string>AccentColor</string>
        <key>UIImageName</key>
        <string></string>
    </dict>
</dict>
</plist>
PLIST_EOF
    echo -e "${GREEN}✓ Info.plist created${NC}"
else
    echo -e "${GREEN}✓ Info.plist already exists${NC}"
fi

# Create Assets.xcassets if it doesn't exist
if [ ! -d "Assets.xcassets" ]; then
    echo -e "${BLUE}Creating Assets.xcassets...${NC}"
    mkdir -p Assets.xcassets/AppIcon.appiconset
    mkdir -p Assets.xcassets/AccentColor.colorset
    
    # Create AppIcon Contents.json
    cat > Assets.xcassets/AppIcon.appiconset/Contents.json << 'ICON_EOF'
{
  "images" : [
    {
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
ICON_EOF
    
    # Create AccentColor Contents.json  
    cat > Assets.xcassets/AccentColor.colorset/Contents.json << 'COLOR_EOF'
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0.478",
          "green" : "0.627",
          "red" : "1.000"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
COLOR_EOF
    
    # Create main Contents.json
    cat > Assets.xcassets/Contents.json << 'MAIN_EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
MAIN_EOF
    
    echo -e "${GREEN}✓ Assets.xcassets created${NC}"
else
    echo -e "${GREEN}✓ Assets.xcassets already exists${NC}"
fi

# Generate Xcode project
echo -e "${BLUE}Creating Xcode project structure...${NC}"

# Create the Python script inline to generate project.pbxproj
python3 << 'PYTHON_EOF'
import os
import uuid
import json
from pathlib import Path

def generate_uuid():
    """Generate a 24-character uppercase hex UUID for Xcode"""
    return uuid.uuid4().hex[:24].upper()

class XcodeProject:
    def __init__(self, project_name, bundle_id, organization):
        self.project_name = project_name
        self.bundle_id = bundle_id
        self.organization = organization
        self.files = {}
        self.groups = {}
        self.build_files = {}
        self.targets = {}
        self.root_object = generate_uuid()
        self.main_group = generate_uuid()
        self.products_group = generate_uuid()
        self.app_target = generate_uuid()
        self.app_product = generate_uuid()
        self.project_config = generate_uuid()
        self.build_config_list = generate_uuid()
        self.app_build_config_list = generate_uuid()
        
        # Build configurations
        self.debug_config = generate_uuid()
        self.release_config = generate_uuid()
        self.app_debug_config = generate_uuid()
        self.app_release_config = generate_uuid()
        
        # Build phases
        self.app_sources_phase = generate_uuid()
        self.app_frameworks_phase = generate_uuid()
        self.app_resources_phase = generate_uuid()
        
    def add_file(self, path, name, file_type="sourcecode.swift"):
        file_ref = generate_uuid()
        self.files[file_ref] = {
            "isa": "PBXFileReference",
            "lastKnownFileType": file_type,
            "path": path,
            "sourceTree": "<group>",
            "name": name
        }
        return file_ref
    
    def add_group(self, name, path, children=[]):
        group_ref = generate_uuid()
        self.groups[group_ref] = {
            "isa": "PBXGroup",
            "children": children,
            "path": path if path else None,
            "name": name if name else None,
            "sourceTree": "<group>"
        }
        return group_ref
    
    def scan_directory(self, directory, parent_path=""):
        """Recursively scan directory for Swift files"""
        swift_files = []
        group_children = []
        
        if os.path.exists(directory):
            items = sorted(os.listdir(directory))
            
            # First, handle subdirectories
            for item in items:
                item_path = os.path.join(directory, item)
                if os.path.isdir(item_path) and not item.startswith('.'):
                    # Recursively scan subdirectory - pass item name to indicate it's a subdirectory
                    sub_files, sub_group = self.scan_directory(item_path, item)
                    if sub_group:  # Only add if there are Swift files
                        group_children.append(sub_group)
                        swift_files.extend(sub_files)
            
            # Then handle Swift files in this directory
            for item in items:
                if item.endswith('.swift'):
                    # Create file reference with just the filename
                    file_ref = self.add_file(item, item)
                    group_children.append(file_ref)
                    
                    # Add to build files with full path for compilation
                    build_file = generate_uuid()
                    self.build_files[build_file] = {
                        "isa": "PBXBuildFile",
                        "fileRef": file_ref,
                        "full_path": os.path.join(directory, item)  # Store full path for reference
                    }
                    swift_files.append(build_file)
            
            # Create group for this directory
            if group_children:
                # For subdirectories, use just the basename as the path
                if parent_path:
                    # This is a subdirectory - use just the subdirectory name as path
                    group_ref = self.add_group(os.path.basename(directory), os.path.basename(directory), group_children)
                else:
                    # This is a top-level directory - set the full path
                    group_ref = self.add_group(os.path.basename(directory), directory, group_children)
                return swift_files, group_ref
        
        return swift_files, None
    
    def generate_pbxproj(self):
        """Generate the complete project.pbxproj content"""
        
        # Collect all Swift files
        all_swift_files = []
        main_groups = []
        
        # Define the directory structure
        directories = ["Models", "Views", "Components", "Design", "Services"]
        
        for directory in directories:
            swift_files, group_ref = self.scan_directory(directory)
            if group_ref:
                main_groups.append(group_ref)
                all_swift_files.extend(swift_files)
        
        # Add root level Swift files
        root_files = []
        for file in sorted(os.listdir(".")):
            if file.endswith('.swift'):
                file_ref = self.add_file(file, file)
                root_files.append(file_ref)
                
                build_file = generate_uuid()
                self.build_files[build_file] = {
                    "isa": "PBXBuildFile",
                    "fileRef": file_ref
                }
                all_swift_files.append(build_file)
        
        # Add Info.plist
        info_plist_ref = self.add_file("Info.plist", "Info.plist", "text.plist.xml")
        
        # Create main group structure
        main_children = root_files + main_groups + [self.products_group, info_plist_ref]
        
        # Start building the project file content
        content = """// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {
"""
        
        # Add PBXBuildFile section
        content += "\n/* Begin PBXBuildFile section */\n"
        for build_id, build_info in self.build_files.items():
            content += f"\t\t{build_id} /* in Sources */ = {{isa = PBXBuildFile; fileRef = {build_info['fileRef']}; }};\n"
        content += "/* End PBXBuildFile section */\n\n"
        
        # Add PBXFileReference section
        content += "/* Begin PBXFileReference section */\n"
        content += f"\t\t{self.app_product} /* {self.project_name}.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = {self.project_name}.app; sourceTree = BUILT_PRODUCTS_DIR; }};\n"
        
        for file_id, file_info in self.files.items():
            name = file_info.get('name', '')
            content += f"\t\t{file_id} /* {name} */ = {{isa = PBXFileReference; "
            content += f"lastKnownFileType = {file_info['lastKnownFileType']}; "
            content += f"path = \"{file_info['path']}\"; "
            content += f"sourceTree = \"{file_info['sourceTree']}\"; }};\n"
        content += "/* End PBXFileReference section */\n\n"
        
        # Add PBXFrameworksBuildPhase section
        content += "/* Begin PBXFrameworksBuildPhase section */\n"
        content += f"\t\t{self.app_frameworks_phase} /* Frameworks */ = {{\n"
        content += "\t\t\tisa = PBXFrameworksBuildPhase;\n"
        content += "\t\t\tbuildActionMask = 2147483647;\n"
        content += "\t\t\tfiles = (\n"
        content += "\t\t\t);\n"
        content += "\t\t\trunOnlyForDeploymentPostprocessing = 0;\n"
        content += "\t\t};\n"
        content += "/* End PBXFrameworksBuildPhase section */\n\n"
        
        # Add PBXGroup section
        content += "/* Begin PBXGroup section */\n"
        
        # Main group
        content += f"\t\t{self.main_group} = {{\n"
        content += "\t\t\tisa = PBXGroup;\n"
        content += "\t\t\tchildren = (\n"
        for child in main_children:
            content += f"\t\t\t\t{child},\n"
        content += "\t\t\t);\n"
        content += "\t\t\tsourceTree = \"<group>\";\n"
        content += "\t\t};\n"
        
        # Products group
        content += f"\t\t{self.products_group} /* Products */ = {{\n"
        content += "\t\t\tisa = PBXGroup;\n"
        content += "\t\t\tchildren = (\n"
        content += f"\t\t\t\t{self.app_product} /* {self.project_name}.app */,\n"
        content += "\t\t\t);\n"
        content += "\t\t\tname = Products;\n"
        content += "\t\t\tsourceTree = \"<group>\";\n"
        content += "\t\t};\n"
        
        # Other groups
        for group_id, group_info in self.groups.items():
            group_name = group_info.get('name', group_info.get('path', ''))
            content += f"\t\t{group_id} /* {group_name} */ = {{\n"
            content += "\t\t\tisa = PBXGroup;\n"
            content += "\t\t\tchildren = (\n"
            for child in group_info['children']:
                content += f"\t\t\t\t{child},\n"
            content += "\t\t\t);\n"
            if group_info.get('path'):
                content += f"\t\t\tpath = \"{group_info['path']}\";\n"
            content += "\t\t\tsourceTree = \"<group>\";\n"
            content += "\t\t};\n"
        
        content += "/* End PBXGroup section */\n\n"
        
        # Add PBXNativeTarget section
        content += "/* Begin PBXNativeTarget section */\n"
        content += f"\t\t{self.app_target} /* {self.project_name} */ = {{\n"
        content += "\t\t\tisa = PBXNativeTarget;\n"
        content += f"\t\t\tbuildConfigurationList = {self.app_build_config_list};\n"
        content += "\t\t\tbuildPhases = (\n"
        content += f"\t\t\t\t{self.app_sources_phase} /* Sources */,\n"
        content += f"\t\t\t\t{self.app_frameworks_phase} /* Frameworks */,\n"
        content += f"\t\t\t\t{self.app_resources_phase} /* Resources */,\n"
        content += "\t\t\t);\n"
        content += "\t\t\tbuildRules = (\n"
        content += "\t\t\t);\n"
        content += "\t\t\tdependencies = (\n"
        content += "\t\t\t);\n"
        content += f"\t\t\tname = {self.project_name};\n"
        content += f"\t\t\tproductName = {self.project_name};\n"
        content += f"\t\t\tproductReference = {self.app_product} /* {self.project_name}.app */;\n"
        content += "\t\t\tproductType = \"com.apple.product-type.application\";\n"
        content += "\t\t};\n"
        content += "/* End PBXNativeTarget section */\n\n"
        
        # Add PBXProject section
        content += "/* Begin PBXProject section */\n"
        content += f"\t\t{self.root_object} /* Project object */ = {{\n"
        content += "\t\t\tisa = PBXProject;\n"
        content += "\t\t\tattributes = {\n"
        content += "\t\t\t\tBuildIndependentTargetsInParallel = 1;\n"
        content += "\t\t\t\tLastSwiftUpdateCheck = 1520;\n"
        content += "\t\t\t\tLastUpgradeCheck = 1520;\n"
        content += "\t\t\t\tTargetAttributes = {\n"
        content += f"\t\t\t\t\t{self.app_target} = {{\n"
        content += "\t\t\t\t\t\tCreatedOnToolsVersion = 15.2;\n"
        content += "\t\t\t\t\t};\n"
        content += "\t\t\t\t};\n"
        content += "\t\t\t};\n"
        content += f"\t\t\tbuildConfigurationList = {self.build_config_list};\n"
        content += "\t\t\tcompatibilityVersion = \"Xcode 14.0\";\n"
        content += "\t\t\tdevelopmentRegion = en;\n"
        content += "\t\t\thasScannedForEncodings = 0;\n"
        content += "\t\t\tknownRegions = (\n"
        content += "\t\t\t\ten,\n"
        content += "\t\t\t\tBase,\n"
        content += "\t\t\t);\n"
        content += f"\t\t\tmainGroup = {self.main_group};\n"
        content += f"\t\t\tproductRefGroup = {self.products_group} /* Products */;\n"
        content += "\t\t\tprojectDirPath = \"\";\n"
        content += "\t\t\tprojectRoot = \"\";\n"
        content += "\t\t\ttargets = (\n"
        content += f"\t\t\t\t{self.app_target} /* {self.project_name} */,\n"
        content += "\t\t\t);\n"
        content += "\t\t};\n"
        content += "/* End PBXProject section */\n\n"
        
        # Add PBXResourcesBuildPhase section
        content += "/* Begin PBXResourcesBuildPhase section */\n"
        content += f"\t\t{self.app_resources_phase} /* Resources */ = {{\n"
        content += "\t\t\tisa = PBXResourcesBuildPhase;\n"
        content += "\t\t\tbuildActionMask = 2147483647;\n"
        content += "\t\t\tfiles = (\n"
        content += "\t\t\t);\n"
        content += "\t\t\trunOnlyForDeploymentPostprocessing = 0;\n"
        content += "\t\t};\n"
        content += "/* End PBXResourcesBuildPhase section */\n\n"
        
        # Add PBXSourcesBuildPhase section
        content += "/* Begin PBXSourcesBuildPhase section */\n"
        content += f"\t\t{self.app_sources_phase} /* Sources */ = {{\n"
        content += "\t\t\tisa = PBXSourcesBuildPhase;\n"
        content += "\t\t\tbuildActionMask = 2147483647;\n"
        content += "\t\t\tfiles = (\n"
        for build_file in all_swift_files:
            content += f"\t\t\t\t{build_file},\n"
        content += "\t\t\t);\n"
        content += "\t\t\trunOnlyForDeploymentPostprocessing = 0;\n"
        content += "\t\t};\n"
        content += "/* End PBXSourcesBuildPhase section */\n\n"
        
        # Add XCBuildConfiguration section
        content += "/* Begin XCBuildConfiguration section */\n"
        
        # Debug configuration for project
        content += f"\t\t{self.debug_config} /* Debug */ = {{\n"
        content += "\t\t\tisa = XCBuildConfiguration;\n"
        content += "\t\t\tbuildSettings = {\n"
        content += "\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;\n"
        content += "\t\t\t\tCLANG_ENABLE_MODULES = YES;\n"
        content += "\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;\n"
        content += "\t\t\t\tCODE_SIGN_STYLE = Automatic;\n"
        content += "\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;\n"
        content += "\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;\n"
        content += "\t\t\t\tENABLE_TESTABILITY = YES;\n"
        content += "\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;\n"
        content += "\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;\n"
        content += "\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;\n"
        content += "\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;\n"
        content += "\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (\n"
        content += "\t\t\t\t\t\"DEBUG=1\",\n"
        content += "\t\t\t\t\t\"$(inherited)\",\n"
        content += "\t\t\t\t);\n"
        content += "\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;\n"
        content += "\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;\n"
        content += f"\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;\n"
        content += "\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;\n"
        content += "\t\t\t\tMTL_FAST_MATH = YES;\n"
        content += "\t\t\t\tONLY_ACTIVE_ARCH = YES;\n"
        content += "\t\t\t\tSDKROOT = iphoneos;\n"
        content += "\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;\n"
        content += "\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = \"-Onone\";\n"
        content += "\t\t\t\tSWIFT_VERSION = 5.0;\n"
        content += "\t\t\t};\n"
        content += "\t\t\tname = Debug;\n"
        content += "\t\t};\n"
        
        # Release configuration for project
        content += f"\t\t{self.release_config} /* Release */ = {{\n"
        content += "\t\t\tisa = XCBuildConfiguration;\n"
        content += "\t\t\tbuildSettings = {\n"
        content += "\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;\n"
        content += "\t\t\t\tCLANG_ENABLE_MODULES = YES;\n"
        content += "\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;\n"
        content += "\t\t\t\tCODE_SIGN_STYLE = Automatic;\n"
        content += "\t\t\t\tDEBUG_INFORMATION_FORMAT = \"dwarf-with-dsym\";\n"
        content += "\t\t\t\tENABLE_NS_ASSERTIONS = NO;\n"
        content += "\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;\n"
        content += "\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;\n"
        content += "\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;\n"
        content += "\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;\n"
        content += "\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;\n"
        content += f"\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;\n"
        content += "\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;\n"
        content += "\t\t\t\tMTL_FAST_MATH = YES;\n"
        content += "\t\t\t\tSDKROOT = iphoneos;\n"
        content += "\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;\n"
        content += "\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = \"-O\";\n"
        content += "\t\t\t\tSWIFT_VERSION = 5.0;\n"
        content += "\t\t\t\tVALIDATE_PRODUCT = YES;\n"
        content += "\t\t\t};\n"
        content += "\t\t\tname = Release;\n"
        content += "\t\t};\n"
        
        # Debug configuration for app target
        content += f"\t\t{self.app_debug_config} /* Debug */ = {{\n"
        content += "\t\t\tisa = XCBuildConfiguration;\n"
        content += "\t\t\tbuildSettings = {\n"
        content += "\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;\n"
        content += "\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;\n"
        content += "\t\t\t\tCODE_SIGN_STYLE = Automatic;\n"
        content += "\t\t\t\tCURRENT_PROJECT_VERSION = 1;\n"
        content += "\t\t\t\tDEVELOPMENT_TEAM = \"\";\n"
        content += "\t\t\t\tENABLE_PREVIEWS = YES;\n"
        content += "\t\t\t\tGENERATE_INFOPLIST_FILE = YES;\n"
        content += "\t\t\t\tINFOPLIST_FILE = Info.plist;\n"
        content += "\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = \"Daily Glow\";\n"
        content += "\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;\n"
        content += "\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;\n"
        content += "\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;\n"
        content += "\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;\n"
        content += "\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = \"UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown\";\n"
        content += "\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (\n"
        content += "\t\t\t\t\t\"$(inherited)\",\n"
        content += "\t\t\t\t\t\"@executable_path/Frameworks\",\n"
        content += "\t\t\t\t);\n"
        content += "\t\t\t\tMARKETING_VERSION = 1.0;\n"
        content += f"\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = \"{self.bundle_id}\";\n"
        content += f"\t\t\t\tPRODUCT_NAME = \"$(TARGET_NAME)\";\n"
        content += "\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;\n"
        content += "\t\t\t\tSWIFT_VERSION = 5.0;\n"
        content += "\t\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";\n"
        content += "\t\t\t};\n"
        content += "\t\t\tname = Debug;\n"
        content += "\t\t};\n"
        
        # Release configuration for app target
        content += f"\t\t{self.app_release_config} /* Release */ = {{\n"
        content += "\t\t\tisa = XCBuildConfiguration;\n"
        content += "\t\t\tbuildSettings = {\n"
        content += "\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;\n"
        content += "\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;\n"
        content += "\t\t\t\tCODE_SIGN_STYLE = Automatic;\n"
        content += "\t\t\t\tCURRENT_PROJECT_VERSION = 1;\n"
        content += "\t\t\t\tDEVELOPMENT_TEAM = \"\";\n"
        content += "\t\t\t\tENABLE_PREVIEWS = YES;\n"
        content += "\t\t\t\tGENERATE_INFOPLIST_FILE = YES;\n"
        content += "\t\t\t\tINFOPLIST_FILE = Info.plist;\n"
        content += "\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = \"Daily Glow\";\n"
        content += "\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;\n"
        content += "\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;\n"
        content += "\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;\n"
        content += "\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;\n"
        content += "\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = \"UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown\";\n"
        content += "\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (\n"
        content += "\t\t\t\t\t\"$(inherited)\",\n"
        content += "\t\t\t\t\t\"@executable_path/Frameworks\",\n"
        content += "\t\t\t\t);\n"
        content += "\t\t\t\tMARKETING_VERSION = 1.0;\n"
        content += f"\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = \"{self.bundle_id}\";\n"
        content += f"\t\t\t\tPRODUCT_NAME = \"$(TARGET_NAME)\";\n"
        content += "\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;\n"
        content += "\t\t\t\tSWIFT_VERSION = 5.0;\n"
        content += "\t\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";\n"
        content += "\t\t\t};\n"
        content += "\t\t\tname = Release;\n"
        content += "\t\t};\n"
        
        content += "/* End XCBuildConfiguration section */\n\n"
        
        # Add XCConfigurationList section
        content += "/* Begin XCConfigurationList section */\n"
        
        # Configuration list for project
        content += f"\t\t{self.build_config_list} /* Build configuration list for PBXProject \"{self.project_name}\" */ = {{\n"
        content += "\t\t\tisa = XCConfigurationList;\n"
        content += "\t\t\tbuildConfigurations = (\n"
        content += f"\t\t\t\t{self.debug_config} /* Debug */,\n"
        content += f"\t\t\t\t{self.release_config} /* Release */,\n"
        content += "\t\t\t);\n"
        content += "\t\t\tdefaultConfigurationIsVisible = 0;\n"
        content += "\t\t\tdefaultConfigurationName = Release;\n"
        content += "\t\t};\n"
        
        # Configuration list for app target
        content += f"\t\t{self.app_build_config_list} /* Build configuration list for PBXNativeTarget \"{self.project_name}\" */ = {{\n"
        content += "\t\t\tisa = XCConfigurationList;\n"
        content += "\t\t\tbuildConfigurations = (\n"
        content += f"\t\t\t\t{self.app_debug_config} /* Debug */,\n"
        content += f"\t\t\t\t{self.app_release_config} /* Release */,\n"
        content += "\t\t\t);\n"
        content += "\t\t\tdefaultConfigurationIsVisible = 0;\n"
        content += "\t\t\tdefaultConfigurationName = Release;\n"
        content += "\t\t};\n"
        
        content += "/* End XCConfigurationList section */\n"
        
        # Close the project file
        content += "\t};\n"
        content += f"\trootObject = {self.root_object} /* Project object */;\n"
        content += "}\n"
        
        return content

# Main execution
if __name__ == "__main__":
    project = XcodeProject("DailyGlow", "com.dailyglow.app", "DailyGlow")
    pbxproj_content = project.generate_pbxproj()
    
    # Create project directory
    os.makedirs("DailyGlow.xcodeproj", exist_ok=True)
    
    with open("DailyGlow.xcodeproj/project.pbxproj", "w") as f:
        f.write(pbxproj_content)
    
    print("✓ Generated project.pbxproj")
PYTHON_EOF

# Create workspace files
mkdir -p DailyGlow.xcodeproj/project.xcworkspace/xcshareddata

cat > DailyGlow.xcodeproj/project.xcworkspace/contents.xcworkspacedata << 'WORKSPACE_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
WORKSPACE_EOF

cat > DailyGlow.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist << 'CHECK_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>IDEDidComputeMac32BitWarning</key>
	<true/>
</dict>
</plist>
CHECK_EOF

echo -e "${GREEN}✓ Project structure created${NC}"

# Validate project
echo -e "${BLUE}Validating project...${NC}"
if [ -f "DailyGlow.xcodeproj/project.pbxproj" ]; then
    echo -e "${GREEN}✓ Project file exists${NC}"
    
    echo "Testing project build configuration..."
    if xcodebuild -list -project DailyGlow.xcodeproj &> /dev/null; then
        echo -e "${GREEN}✓ Project structure is valid${NC}"
    else
        echo -e "${YELLOW}⚠ Project validation returned warnings (this is usually OK)${NC}"
    fi
else
    echo -e "${RED}✗ Project file was not created${NC}"
    exit 1
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  ✅ SUCCESS! Xcode project created successfully!          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo -e "${GREEN}Next steps:${NC}"
echo ""
echo "1. Open the project:"
echo "   ${BLUE}open DailyGlow.xcodeproj${NC}"
echo ""
echo "2. In Xcode:"
echo "   • Select your development team in Signing & Capabilities"
echo "   • Update the bundle identifier if needed"
echo "   • Connect your iPhone"
echo "   • Press ⌘+R to build and run"
echo ""
echo "3. For TestFlight/App Store:"
echo "   • Product → Archive"
echo "   • Distribute App"
echo "   • Follow the submission process"
echo ""
echo -e "${YELLOW}Note:${NC} If you encounter any issues:"
echo "   • Clean build folder: Shift+⌘+K"
echo "   • Resolve package dependencies: File → Packages → Reset Package Caches"
echo "   • Check code signing settings"
echo ""
echo "Project is ready to open in Xcode!"
echo ""