import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")          // Firebase / Google Services
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.askiman.ask_iman"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true  // ADDED: Enable desugaring
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.askiman.ask_iman"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true  // ADDED: Enable multiDex
    }

    val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(keystorePropertiesFile.inputStream())
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias") ?: "askiman"
            keyPassword = keystoreProperties.getProperty("keyPassword") ?: ""
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) } ?: file("../../askiman_upload.keystore")
            storePassword = keystoreProperties.getProperty("storePassword") ?: ""
            enableV1Signing = true
            enableV2Signing = true
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            ndk {
                debugSymbolLevel = "SYMBOL_TABLE"
            }
            packaging {
                jniLibs {
                    useLegacyPackaging = true
                }
            }
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            packaging {
                jniLibs {
                    keepDebugSymbols.add("**/*.so")
                }
            }
        }
    }
}

// ADDED: Core library desugaring dependency + ML Kit text-recognition scripts
// (R8 needs all scripts present since google_mlkit_text_recognition references
// every TextRecognizerOptions subclass at once)
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation("com.google.mlkit:text-recognition:16.0.1")
    implementation("com.google.mlkit:text-recognition-chinese:16.0.1")
    implementation("com.google.mlkit:text-recognition-devanagari:16.0.1")
    implementation("com.google.mlkit:text-recognition-japanese:16.0.1")
    implementation("com.google.mlkit:text-recognition-korean:16.0.1")
}

flutter {
    source = "../.."
}
