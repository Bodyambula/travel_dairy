plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.travel_dairy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.travel_dairy"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    flavorDimensions.add("environment")

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Travel Dev")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".stg"
            versionNameSuffix = "-stg"
            resValue("string", "app_name", "Travel QA")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "Travel Dairy")
        }
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

// Fix for AGP 8.x: Flutter expects APKs in ROOT_PROJECT/build/app/outputs/flutter-apk/
afterEvaluate {
    tasks.forEach { task ->
        if (task.name.startsWith("assemble")) {
            task.doLast {
                try {
                    // Actual build directory of the app module (android/app/build)
                    val appBuildDir = layout.buildDirectory.get().asFile
                    val apkDir = File(appBuildDir, "outputs/apk")
                    
                    // Root build directory where Flutter looks for outputs (project_root/build)
                    // project.rootDir is 'android/', so project.rootDir.parentFile is 'project_root/'
                    val rootDir = project.rootDir.parentFile
                    val flutterApkDir = File(rootDir, "build/app/outputs/flutter-apk")
                    
                    if (apkDir.exists()) {
                        flutterApkDir.mkdirs()
                        apkDir.walkTopDown().forEach { file ->
                            if (file.extension == "apk") {
                                file.copyTo(File(flutterApkDir, file.name), overwrite = true)
                            }
                        }
                    }
                } catch (e: Exception) {
                    // Silently skip, let Flutter tool handle errors if needed
                }
            }
        }
    }
}
