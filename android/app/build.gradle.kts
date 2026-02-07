plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.template_app"
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
        applicationId = "com.example.template_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions("default")
    productFlavors {
        create("prd") {
            dimension = "default"
            resValue("string", "app_name", "Template App")
        }
        create("hom") {
            dimension = "default"
            versionNameSuffix = ".hom"
            resValue("string", "app_name", "Template App - Homologação")
            applicationIdSuffix = ".hom"
        }
        create("dev") {
            dimension = "default"
            versionNameSuffix = ".dev"
            resValue("string", "app_name", "Template App - Desenvolvimento")
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
