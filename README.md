# NEPSE Pro - Setup and Run Guide

Follow these step-by-step instructions to get the NEPSE Pro Flutter application running on your laptop/PC.

## Prerequisites

Before running the application, ensure you have the following installed on your machine:

1. **Flutter SDK:** 
   - Download the latest stable version of the Flutter SDK from the [official Flutter website](https://docs.flutter.dev/get-started/install/windows).
   - Extract the zip file and add the `flutter/bin` directory to your system's `PATH` environment variable.
   - Run `flutter doctor` in your terminal to verify the installation and install any missing components (like Android Studio or Visual Studio for Windows desktop development).

2. **Code Editor / IDE:**
   - Install [Visual Studio Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio).
   - If using VS Code, install the **Flutter** and **Dart** extensions.

## Step-by-Step Guide to Run the App

### Step 1: Open the Project
1. Open your terminal or command prompt.
2. Navigate to the folder where the app was generated:
   ```bash
   cd C:\Users\cwc\Desktop\mana\stitch_nepse_portfolio_tracker\app
   ```
   *(Alternatively, you can open this `app` folder directly in VS Code or Android Studio).*

### Step 2: Fetch Dependencies
The app relies on external packages like `supabase_flutter` and `google_fonts`. To download them, run the following command in your terminal:
```bash
flutter pub get
```

### Step 3: Choose a Target Device
You can run the app on several different platforms from your PC:
- **Windows Desktop App:** This is the easiest way to test it directly on your laptop without an emulator.
- **Web Browser (Chrome/Edge):** Good for quick UI testing.
- **Android Emulator:** If you have Android Studio installed and an emulator set up.

To see a list of available devices, run:
```bash
flutter devices
```

### Step 4: Run the Application
To launch the app, simply run:
```bash
flutter run
```
* If you have multiple devices available, the terminal will ask you to press a number (e.g., `1` for Windows, `2` for Chrome) to choose where to launch the app.
* Once you make a selection, the app will compile and launch!

---

## Testing Supabase Authentication
1. The app will boot up into the **Onboarding Screen**.
2. Click **Sign Up** to create a new user using an email and password.
3. Depending on your Supabase settings, you may need to check your email to verify the account, or it will log you in immediately.
4. Once logged in, you will be redirected to the **Dashboard Screen** with the bottom navigation bar.
5. Click the **+ Add** floating button to test the Add New Script page!
