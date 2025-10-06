# 📱 Setup Guide: Running Daily Glow on Your iPhone

This guide will walk you through setting up and running Daily Glow on your actual iPhone device.

## Prerequisites

- ✅ Mac with Xcode 15.0+ installed ([Download here](https://apps.apple.com/app/xcode/id497799835))
- ✅ iPhone running iOS 16.0 or later
- ✅ Lightning/USB-C cable to connect your iPhone
- ✅ Apple ID (free or paid developer account)

## Part 1: Create Xcode Project

### Step 1: Open Xcode
1. Open **Xcode** from your Applications folder
2. If this is your first time, Xcode may install additional components (this is normal)

### Step 2: Create New Project
1. Click **"Create New Project"** (or File > New > Project)
2. In the template chooser:
   - Select **"iOS"** at the top
   - Choose **"App"** template
   - Click **"Next"**

### Step 3: Configure Project Settings
Fill in the following:
- **Product Name**: `DailyGlow`
- **Team**: Select your Apple ID (see "Setting Up Your Team" below if empty)
- **Organization Identifier**: `com.yourname.dailyglow` (use your own identifier)
- **Bundle Identifier**: Will auto-fill as `com.yourname.dailyglow.DailyGlow`
- **Interface**: Select **SwiftUI**
- **Language**: Select **Swift**
- **Storage**: Core Data - **UNCHECKED**
- **Include Tests**: Optional (can leave checked or unchecked)

Click **"Next"**

### Step 4: Choose Save Location
1. Navigate to: `/Users/admin/Desktop/Affirmations`
2. Click **"Create"**
3. If prompted about existing files, choose **"Merge"** or **"Replace"**

### Step 5: Delete Default Files
Xcode creates some default files we don't need:
1. In the Project Navigator (left sidebar), select these files:
   - `ContentView.swift` (the default one)
   - Any `Preview Content` folder
2. Right-click and select **"Delete"**
3. Choose **"Move to Trash"**

## Part 2: Add Project Files to Xcode

### Step 6: Add All Folders
1. In Xcode, right-click on the **"DailyGlow"** folder (blue icon at top of navigator)
2. Select **"Add Files to DailyGlow"**
3. Navigate to `/Users/admin/Desktop/Affirmations`
4. **Select ALL these folders** (hold Command to multi-select):
   - `Models`
   - `Views`
   - `Components`
   - `Design`
   - `Services`
5. **Important**: Check these options at the bottom:
   - ✅ **"Copy items if needed"**
   - ✅ **"Create groups"** (not "Create folder references")
   - ✅ **"Add to targets: DailyGlow"**
6. Click **"Add"**

### Step 7: Verify File Structure
Your Project Navigator should now look like this:
```
DailyGlow
├── DailyGlowApp.swift
├── Models/
│   ├── Affirmation.swift
│   ├── Category.swift
│   ├── UserPreferences.swift
│   └── Achievement.swift
├── Views/
│   ├── Main/
│   ├── Onboarding/
│   ├── Paywall/
│   ├── Journal/
│   ├── Settings/
│   └── Widgets/
├── Components/
├── Design/
└── Services/
```

## Part 3: Configure Code Signing

### Step 8: Setting Up Your Team (First-time setup)

If you don't have a team selected:

1. In Xcode, go to **Xcode > Settings** (or Preferences)
2. Click **"Accounts"** tab
3. Click **"+"** at bottom left
4. Select **"Apple ID"**
5. Sign in with your Apple ID
6. Close Settings

### Step 9: Configure Signing & Capabilities
1. Click on the **DailyGlow project** (blue icon at top)
2. Select the **DailyGlow target** in the main area
3. Click **"Signing & Capabilities"** tab
4. Under **"Signing"**:
   - Check ✅ **"Automatically manage signing"**
   - **Team**: Select your Apple ID team
   - **Bundle Identifier**: Should be unique (e.g., `com.yourname.dailyglow`)

### Step 10: Fix Any Issues
If you see warnings:
- **"Failed to register bundle identifier"**: Change the bundle ID slightly (add numbers or your initials)
- **"Provisioning profile doesn't include signing certificate"**: Make sure you're logged into Xcode with your Apple ID

## Part 4: Connect Your iPhone

### Step 11: Trust Your Computer
1. Connect your iPhone to your Mac with a cable
2. **On your iPhone**: You may see "Trust This Computer?" - tap **"Trust"**
3. Enter your iPhone passcode if prompted
4. **On Mac**: You may need to confirm trust

### Step 12: Select Your Device
1. In Xcode, at the top near the Play button, you'll see a device selector
2. Click it and select **your iPhone's name** from the list
3. It should show something like "iPhone 15 Pro" or "John's iPhone"

## Part 5: Run on Your iPhone! 🚀

### Step 13: Build and Run
1. Click the **▶️ Play button** at the top left of Xcode
2. Or press **⌘ + R** (Command + R)
3. Xcode will:
   - Compile the code (this takes 30-60 seconds first time)
   - Sign the app
   - Install it on your iPhone
   - Launch it automatically

### Step 14: Trust Developer Certificate (First time only)
The first time you run the app, you'll see an error on your iPhone:

**"Untrusted Developer"**

To fix this:
1. On your **iPhone**, go to:
   - **Settings** > **General** > **VPN & Device Management**
   - (Or **Settings** > **General** > **Profiles & Device Management**)
2. Find your **Apple ID** or **email** under "Developer App"
3. Tap it and tap **"Trust [Your Name]"**
4. Confirm by tapping **"Trust"** again
5. Go back to Xcode and click the Play button again

### Step 15: Enjoy! 🎉
The app should now launch on your iPhone!

## Part 6: Making Changes

### To Edit and Update:
1. Make changes in Xcode
2. Press **⌘ + R** to rebuild and run
3. The app will automatically update on your iPhone

### To Stop the App:
- Click the **⬛ Stop button** in Xcode
- Or quit the app normally on your iPhone

## Troubleshooting

### Problem: "Build Failed" with Swift Errors

**Solution**: Some files might not be in the target
1. Select any file with errors in Project Navigator
2. In the right panel, check **"Target Membership"**
3. Make sure **"DailyGlow"** is checked ✅

### Problem: "No code signing identities found"

**Solution**: 
1. Go to Xcode > Settings > Accounts
2. Select your Apple ID
3. Click "Download Manual Profiles"
4. Try building again

### Problem: "App is already running"

**Solution**:
1. Click the Stop button (⬛) in Xcode
2. Wait a few seconds
3. Try running again

### Problem: "Device locked"

**Solution**:
- Unlock your iPhone
- Keep it unlocked during installation

### Problem: Swift Package Manager errors

**Solution**:
1. File > Packages > Reset Package Caches
2. File > Packages > Resolve Package Versions
3. Clean build folder: Product > Clean Build Folder (⇧⌘K)

### Problem: "iPhone is not available"

**Solution**:
1. Disconnect and reconnect the cable
2. In Xcode: Window > Devices and Simulators
3. Make sure your iPhone appears and shows "Connected"

### Problem: Xcode can't find files

**Solution**:
1. Make sure you added files as "groups" not "folder references"
2. Right-click the DailyGlow folder > "Add Files to DailyGlow"
3. Select all folders again, ensuring "Create groups" is selected

## Advanced: Running Without Cable (Wireless Debugging)

Once your iPhone is set up:

1. Window > Devices and Simulators
2. Select your iPhone
3. Check ✅ "Connect via network"
4. You can now disconnect the cable!
5. Your iPhone will appear in the device list with a network icon

## Performance Tips

### First Launch
- First build takes 1-2 minutes (compiling all files)
- Subsequent builds are much faster (only changed files)
- First launch on device may take 10-15 seconds

### For Faster Development:
1. Use the iOS Simulator for quick testing:
   - Select any iPhone simulator from device menu
   - Runs faster than physical device
   - Good for UI work
2. Use physical device for:
   - Testing haptics
   - Camera features (if added)
   - Real-world performance
   - Testing with actual data

## What to Expect

When the app launches on your iPhone, you'll see:

1. **First Time**: Beautiful onboarding flow
   - Welcome screen
   - Benefits explanation  
   - Name input
   - Mood selection
   - Category picker
   - Notification setup
   - Premium pitch
   - Completion screen

2. **After Onboarding**: Main app with 4 tabs
   - **Today**: Swipeable affirmation cards
   - **Favorites**: Your saved affirmations
   - **Journal**: Mood tracking and entries
   - **Settings**: Customization and preferences

3. **Try These Features**:
   - Swipe right to favorite an affirmation
   - Swipe left to see the next one
   - Write a journal entry
   - Check out the achievements system
   - Customize your theme

## Need More Help?

- **Xcode Documentation**: Help > Developer Documentation in Xcode
- **Apple Developer**: https://developer.apple.com/documentation
- **GitHub Issues**: Open an issue in the repository

## Free vs Paid Apple Developer Account

### Free Account (Apple ID)
- ✅ Can run apps on your own device
- ✅ Free forever
- ⚠️ App expires after 7 days (need to reinstall)
- ⚠️ Can't distribute to others
- ⚠️ Limited to 3 apps at once

### Paid Developer Account ($99/year)
- ✅ Apps don't expire
- ✅ Can publish to App Store
- ✅ Can add up to 100 test devices
- ✅ Access to beta features
- ✅ TestFlight distribution

For personal use, the **free account is perfect**!

---

**Congratulations!** 🎉 You should now have Daily Glow running on your iPhone!

If you encounter any issues not covered here, check the project's GitHub issues or the HANDOFF_GUIDE.md for more technical details.
