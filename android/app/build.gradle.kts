plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "org.surrel.coairence"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "org.surrel.coairence"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Add flavor dimension and product flavors
    flavorDimensions += "mode"

    productFlavors {
        create("dev") {
            dimension = "mode"
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }
        create("staging") {
            dimension = "mode"
            applicationIdSuffix = ".profile"
            versionNameSuffix = "-profile"
        }
        create("prod") {
            dimension = "mode"
            // No suffix — uses default applicationId
        }
    }

    signingConfigs {
        create("release") {
            // Configuration-time: safe, no failure, no prompts
            storeFile = System.getenv("KEYSTORE")?.let { file(it) }
            keyAlias = System.getenv("KEY")
            storePassword = System.getenv("KEYSTORE_PASSWORD")
            keyPassword = System.getenv("KEYSTORE_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }

    // Execution-time: only fails if you actually try to build/bundle release
    tasks.matching { it.name.contains("Release") }.configureEach {
        doFirst {
            val required = listOf("KEYSTORE", "KEY", "KEYSTORE_PASSWORD", "KEY_PASSWORD")
            val missing = required.filter { System.getenv(it).isNullOrBlank() }
            if (missing.isNotEmpty()) {
                throw GradleException(
                    "Missing env vars for release signing: ${missing.joinToString()}\n" +
                    "Set them and re-run, e.g.:\n" +
                    "  read -s -p 'Keystore password: ' KEYSTORE_PASSWORD; echo\n" +
                    "  export KEYSTORE=/path/to/your.jks KEY=your-alias KEYSTORE_PASSWORD\n" +
                    "  ./gradlew bundleProdRelease"
                )
            }
        }
    }

    applicationVariants.all {
        val variant = this
        variant.outputs.all {
            (this as com.android.build.gradle.internal.api.ApkVariantOutputImpl)
                .outputFileName = "app-${variant.flavorName}-${variant.buildType.name}.apk"
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
