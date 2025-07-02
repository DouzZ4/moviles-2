plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Agregado para Google Services
}

android {
    namespace = "com.example.checkinc"
    compileSdk = 35 // Actualizado a 35
    buildToolsVersion = "35.0.0" // Añadido explícitamente
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.checkinc"
        minSdk = 21
        targetSdk = 35 // Actualizado a 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 🔥 Firebase BoM para manejar versiones automáticamente
    implementation(platform("com.google.firebase:firebase-bom:32.7.2"))

}
