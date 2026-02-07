plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.habitos"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.habitos"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions("default")
    productFlavors {
        create("prd") {
            dimension = "default"
            resValue("string", "app_name", "Habitos")
        }
        create("hom") {
            dimension = "default"
            versionNameSuffix = ".hom"
            resValue("string", "app_name", "Habitos - Homologação")
            applicationIdSuffix = ".hom"
        }
        create("dev") {
            dimension = "default"
            versionNameSuffix = ".dev"
            resValue("string", "app_name", "Habitos - Desenvolvimento")
            applicationIdSuffix = ".dev"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
