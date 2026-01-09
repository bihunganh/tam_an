plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // This is required!
}
android {
    namespace = "com.example.tam_an"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion


    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.tam_an"
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        minSdk = 24

        // Match this to your compileSdk
        targetSdk = 36
    }
}