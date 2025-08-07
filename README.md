# LastBenchCap Common Gradle Plugin

A Gradle plugin that provides common configuration for LastBenchCap libraries, minimizing duplication and ensuring consistency across all projects.

## Features

- **Common Dependencies**: Spring Boot starters, JWT, ULID, Lombok, etc.
- **Standardized Testing**: JUnit 5, Mockito, H2 database
- **Publishing Configuration**: GitHub Packages integration
- **Code Coverage**: JaCoCo integration
- **Minimal Configuration**: Each library only needs ~10 lines of build.gradle

## Usage

### In Your Library's build.gradle

```gradle
plugins {
    id 'com.lastbenchcap.common.gradle' version '+'
}

// Optional: Add library-specific dependencies
dependencies {
    api 'my-specific-dependency:1.0.0'
}
```

### Required gradle.properties

```properties
# Version Management
library.version=1.0.0

# GitHub Configuration
github.owner=your-github-username
github.repo=your-repo-name

# Library Information
library.group=com.lastbenchcap
library.artifactId=your-library-name
library.name=Your Library Name
library.description=Description of your library
```

## Installation

### Option 1: GitHub Packages (Recommended)

Add to your `settings.gradle`:

```gradle
pluginManagement {
    repositories {
        maven {
            url = uri("https://maven.pkg.github.com/rmarap/lastbenchcap-common-gradle")
            credentials {
                username = project.findProperty("gpr.user") ?: System.getenv("GITHUB_USERNAME")
                password = project.findProperty("gpr.key") ?: System.getenv("GITHUB_TOKEN")
            }
        }
        gradlePluginPortal()
        mavenCentral()
    }
}
```

### Option 2: Local Development

For local development, you can use the plugin directly:

```gradle
// In settings.gradle
includeBuild '/Users/rammarappan/Projects/spikes-2025/lastbenchcap-common-gradle'

// In build.gradle
plugins {
    id 'com.lastbenchcap.common.gradle'
}
```

## What the Plugin Provides

### Applied Plugins
- `java-library`
- `maven-publish`
- `jacoco`
- `org.springframework.boot`
- `io.spring.dependency-management`

### Common Dependencies
- Spring Boot starters (data-jpa, security, web, validation, aop)
- JWT libraries
- ULID creator
- Lombok
- OpenAPI documentation
- Test dependencies (JUnit 5, Mockito, H2)

### Configuration
- Java 21 toolchain
- GitHub Packages publishing
- JaCoCo code coverage
- Sources and Javadoc JARs
- Standardized POM metadata

## Development

### Building the Plugin

```bash
cd /Users/rammarappan/Projects/spikes-2025/lastbenchcap-common-gradle
./gradlew build
```

### Publishing the Plugin

```bash
./gradlew publish
```

### Testing the Plugin

```bash
./gradlew test
```

## Version History

- `1.0.23` - Updated artifactId to `common-gradle`, improved configuration
- `1.0.0` - Initial release with common library configuration

## License

MIT License 