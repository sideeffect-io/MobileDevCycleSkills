plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "example.consumer"
    compileSdk = 37

    defaultConfig { minSdk = 24 }

    buildFeatures { compose = true }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    lint {
        warningsAsErrors = true
        disable += "AndroidGradlePluginVersion"
    }
}

dependencies {
    implementation(project(":app-composition"))
}

val boundaryNegativeCompile = tasks.register<JavaCompile>("compileBoundaryNegativeFeatureAccess") {
    source(fileTree("src/boundaryNegative/java"))
    classpath = files()
    destinationDirectory.set(layout.buildDirectory.dir("boundary-negative/classes"))
    options.release.set(17)
    options.compilerArgs.add("-proc:none")
}

afterEvaluate {
    val debugJavaCompile = tasks.named<JavaCompile>("compileDebugJavaWithJavac")
    boundaryNegativeCompile.configure {
        dependsOn(debugJavaCompile)
        classpath = debugJavaCompile.get().classpath
    }
}
