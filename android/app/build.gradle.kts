import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing, from the environment (CI) or android/key.properties (a
// maintainer's machine), in that order. With neither, release builds fall back
// to the debug key so `flutter build apk` and `flutter run --release` work for
// everyone; such a build installs fine but cannot update a store install.
// `just package-android` names those files "-debug-signed" so they are not
// mistaken for the real thing.
//
// key.properties, which android/.gitignore keeps out of git:
//   storeFile=/absolute/path/to/upload.jks
//   storePassword=...
//   keyAlias=upload
//   keyPassword=...
val keyProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

fun signingValue(env: String, property: String): String? =
    System.getenv(env)?.takeIf { it.isNotBlank() } ?: keyProperties.getProperty(property)

val releaseStoreFile = signingValue("ANDROID_KEYSTORE_PATH", "storeFile")

android {
    namespace = "red.tix.tix_mobile"
    // flutter_local_notifications 23 compiles against SDK 37.
    compileSdk = maxOf(flutter.compileSdkVersion, 37)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications uses java.time on every API level.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "red.tix.tix_mobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseStoreFile != null) {
            create("release") {
                storeFile = file(releaseStoreFile)
                storePassword = signingValue("ANDROID_KEYSTORE_PASSWORD", "storePassword")
                keyAlias = signingValue("ANDROID_KEY_ALIAS", "keyAlias")
                keyPassword = signingValue("ANDROID_KEY_PASSWORD", "keyPassword")
            }
        }
    }

    // libtix (the embedded engine) is ~32 MB per ABI. Stored uncompressed it
    // is mapped straight from the APK, 16 KB aligned by AGP 8.5.1+, which
    // Google Play requires for Android 15 devices with 16 KB pages.
    // scripts/engine-check.sh verifies both in CI.
    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }

    // AGP writes a list of the app's dependencies into every APK and bundle,
    // encrypted with a key only Google can read. Google Play reads it from the
    // bundle; in an APK it is an opaque blob that F-Droid's scanner rejects and
    // nobody else can check, so APKs (GitHub releases, F-Droid) go without.
    dependenciesInfo {
        includeInApk = false
        includeInBundle = true
    }

    buildTypes {
        release {
            signingConfig =
                if (releaseStoreFile != null) {
                    signingConfigs.getByName("release")
                } else {
                    logger.warn("tix-mobile: no release keystore configured, signing the release build with the debug key")
                    signingConfigs.getByName("debug")
                }
            // Gson, which flutter_local_notifications uses, needs its rules
            // under R8.
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
