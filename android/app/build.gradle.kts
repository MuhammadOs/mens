import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties from android/keystore.properties (kept out of VCS)
val keystorePropertiesFile = rootProject.file("keystore.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.muhammados.mens"  // Updated to match applicationId
    compileSdk = 36  // Updated to Android 15/16 for plugin compatibility
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Updated to unique application ID - CHANGE THIS to your own package name
        applicationId = "com.muhammados.mens"
        // Google Play requires minimum SDK 21 (Android 5.0)
        minSdk = flutter.minSdkVersion
        // Google Play requires targeting Android 15 (API 35) for new apps in 2025
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                val keyAliasVal = keystoreProperties.getProperty("keyAlias")
                val keyPasswordVal = keystoreProperties.getProperty("keyPassword")
                val storeFileVal = keystoreProperties.getProperty("storeFile")
                val storePasswordVal = keystoreProperties.getProperty("storePassword")

                if (keyAliasVal != null) keyAlias = keyAliasVal
                if (keyPasswordVal != null) keyPassword = keyPasswordVal
                if (storeFileVal != null) storeFile = file(storeFileVal)
                if (storePasswordVal != null) storePassword = storePasswordVal
            }
        }
    }

    buildTypes {
        release {
            // Sign with release keystore for production builds if configured.
            // If no keystore is provided (keystorePropertiesFile missing), Gradle will use the debug key.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // Enable code shrinking, obfuscation, and optimization
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
