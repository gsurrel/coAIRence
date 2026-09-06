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
            signingConfig = if (!System.getenv("KEYSTORE").isNullOrBlank()) signingConfigs.getByName("release") else null
        }
    }

    // Execution-time: only fails if you actually try to build/bundle release
    tasks.matching { it.name.contains("Release") }.configureEach {
        doFirst {
            val skipKeystore = !System.getenv("SKIP_KEYSTORE").isNullOrBlank()
            if (!skipKeystore) {
                val required = listOf("KEYSTORE", "KEYSTORE_PASSWORD", "KEY")
                val missing = required.filter { System.getenv(it).isNullOrBlank() }
                if (missing.isNotEmpty()) {
                    throw GradleException(
                        "Missing env vars for release signing: ${missing.joinToString()}\n" +
                        "Set them and re-run, e.g.:\n" +
                        "  read -s -p 'Keystore password: ' KEYSTORE_PASSWORD; echo\n" +
                        "  export KEYSTORE=/path/to/your.jks KEY=your-alias KEYSTORE_PASSWORD\n" +
                        "  ./gradlew assembleProdRelease"
                    )
                }
            }
        }
    }

    // Split-ABI version codes: F-Droid's fdroiddata metadata for this app runs
    // `flutter build apk --flavor=prod --split-per-abi` once per Build block,
    // then picks one output APK per block via `output:`. Since all three ABI
    // APKs are produced in the same invocation, they'd otherwise all carry the
    // same versionCode from `pubspec.yaml`. Gradle must bake in distinct codes
    // here so each ABI's baked-in versionCode matches fdroiddata's
    // VercodeOperation (`%c * 10 + N`) for that ABI.
    val abiVersionCodes = mapOf(
        "armeabi-v7a" to 1,
        "arm64-v8a" to 2,
        "x86_64" to 3
    )

    applicationVariants.all {
        val variant = this
        variant.outputs.all {
            val output = this as com.android.build.gradle.internal.api.ApkVariantOutputImpl
            val abi = output.filters.find { it.filterType == "ABI" }?.identifier

            output.outputFileName = "app-${variant.flavorName}-${variant.buildType.name}" +
                (abi?.let { "-$it" } ?: "") + ".apk"

            val abiCode = abiVersionCodes[abi]
            if (abiCode != null) {
                output.versionCodeOverride = variant.versionCode * 10 + abiCode
            }
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
