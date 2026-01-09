plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Đảm bảo namespace trùng với applicationId của bạn
    namespace = "com.example.tam_an"
    ndkVersion = flutter.ndkVersion

    // Giữ mức 36 để các thư viện (shared_prefs, image_picker) không báo lỗi
    compileSdk = 36

    compileOptions {
        // Vẫn giữ Desugaring để hỗ trợ các hàm Java 8+ (như Timezone/Notification) một cách an toàn nhất
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.tam_an"
        // Redmi Note 11T Pro chạy Android 12/13, minSdk 24 là cực kỳ an toàn
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            // Tối ưu hóa cho chip 64-bit của Redmi Note 11T Pro
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Hỗ trợ đồng nhất các tính năng Java hiện đại
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}