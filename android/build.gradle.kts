allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}
subprojects {
    val configureProject = Action<Project> {
        val android = extensions.findByName("android")
        if (android != null) {
            val base = android as? com.android.build.gradle.BaseExtension
            if (base != null) {
                base.compileSdkVersion(36)
                base.defaultConfig.targetSdkVersion(36)
            }
        }
    }
    if (state.executed) {
        configureProject.execute(this)
    } else {
        afterEvaluate(configureProject)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
