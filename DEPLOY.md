# Play Store Deployment Guide

## 1. Generate Signing Key

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
        -keysize 2048 -validity 10000 -alias upload
```

## 2. Create key.properties

Create `android/key.properties`:

```properties
storePassword=<your_store_password>
keyPassword=<your_key_password>
keyAlias=upload
storeFile=/Users/YOUR_USERNAME/upload-keystore.jks
```

## 3. Update build.gradle.kts

Add to `android/app/build.gradle.kts`:

```kotlin
// At the top, after plugins
import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Inside android { }
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        // ... rest of config
    }
}
```

## 4. Build App Bundle

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## 5. Play Store Requirements

### App Information
- App Name: التفاسير - Quran Tafseer
- Short Description: تفاسير القرآن الكريم من 10 مصادر موثوقة
- Full Description: (Use README content)

### Graphics
- Icon: 512x512 PNG
- Feature Graphic: 1024x500 PNG
- Phone Screenshots: At least 2 (16:9 or 9:16)

### Content Rating
- Complete IARC questionnaire
- Religion category
- No ads, no in-app purchases

### Privacy Policy
- Host privacy policy online (use content from `privacy_policy_screen.dart`)

## 6. Testing

```bash
# Build APK for testing
flutter build apk --release

# Install on device
adb install build/app/outputs/flutter-apk/app-release.apk
```
