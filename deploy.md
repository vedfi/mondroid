# Deployment Instructions

This document provides the steps to build and deploy a release version of the application for both Android and iOS.

## iOS

TBD

## Android

To build a signed release APK for Android, you need to generate a signing key and provide its details to the Gradle build system. These files are not checked into version control for security reasons.

### 1. Create a Signing Key

You need a signing key to sign your application. This key is stored in a file called a "keystore". We will use the `keytool` command (which is part of the Java Development Kit) to generate one.

From the root of the project, run the following command:

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

- You will be prompted to create a password for the keystore. **Remember this password.**
- It will also ask for your name, organization, etc. You can fill these out as you see fit.
- This will create a file named `upload-keystore.jks` inside the `android/app/` directory.

### 2. Create the Key Properties File

Gradle needs to know the password and alias for your keystore. You provide this information in a `key.properties` file.

Create a new file at `android/key.properties` and add the following content:

```properties
storePassword=<YOUR_STORE_PASSWORD>
keyPassword=<YOUR_KEY_PASSWORD>
keyAlias=upload
storeFile=/path/to/your/mondroid/project/android/app/upload-keystore.jks
```

- **Important:** Replace `<YOUR_STORE_PASSWORD>` and `<YOUR_KEY_PASSWORD>` with the password you created in Step 1.
- Make sure `storeFile` is the absolute path to the `upload-keystore.jks` file you just created.

### 3. Build the Release APK

Now that the signing information is in place, you can build the signed APK using the Flutter CLI.

From the root of the project, run:

```bash
flutter build apk --release
```

If the build is successful, you will find the signed APK at `build/app/outputs/flutter-apk/app-release.apk`.

### 4. Install on a Device

To install the APK on a real device, you can use the Android Debug Bridge (`adb`).

First, if you have a previous debug version of the app installed, you must uninstall it, as it was signed with a different key.

```bash
adb uninstall com.vedfi.mondroid
```

Then, you can install the new signed APK:

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 5. Setup CI

To enable the GitHub Actions workflow to automatically build and sign your APK, you need to add the following secrets to your repository at **Settings** > **Secrets and variables** > **Actions**.

- **`KEYSTORE_JKS_BASE64`**: The base64-encoded content of your keystore file. You can get this by running the following command in your terminal from the project's root directory:
  ```bash
  base64 -i android/upload-keystore.jks
  ```
  Copy the entire output and paste it as the secret's value.

- **`STORE_PASSWORD`**: The password you chose for your keystore when you created it.

- **`KEY_PASSWORD`**: The key password. This should be the same as the store password. 