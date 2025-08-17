# LastBenchCap Common Gradle Plugin

A comprehensive Gradle plugin ecosystem that provides common configuration for LastBenchCap projects, minimizing duplication and ensuring consistency across all libraries and services.

## Overview

This project provides two main plugins:

1. **`com.lastbenchcap.common.gradle`** - Main plugin for libraries and services
2. **`com.lastbenchcap.repo-management-settings`** - Settings plugin for centralized repository management

## Features

- **Common Dependencies**: Spring Boot starters, JWT, ULID, Lombok, etc.
- **Standardized Testing**: JUnit 5, Mockito, H2 database
- **Publishing Configuration**: GitHub Packages integration
- **Code Coverage**: JaCoCo integration
- **Centralized Repository Management**: Single configuration for all GitHub Packages repositories
- **Minimal Configuration**: Each project only needs ~10 lines of configuration

## Quick Start

### For Libraries and Services

#### 1. Create gradle.properties

```properties
# Version Management
library.version=1.0.0

# GitHub Configuration
github.owner=your-github-username
github.repo=your-repo-name

# Library Information
library.group=com.lastbenchcap
library.artifactId=your-project-name
library.name=Your Project Name
library.description=Description of your project

# Repository Configuration
lastbenchcap.github.repos.file=lastbenchcap-repos.txt
lastbenchcap.github.owner=your-github-username
```

#### 2. Create lastbenchcap-repos.txt

```txt
# GitHub repositories hosting internal Maven packages
lastbenchcap-common
lastbenchcap-common-gradle
# Add other repositories as needed
```

#### 3. Configure settings.gradle

```gradle
pluginManagement {
    repositories {
        mavenLocal()
        gradlePluginPortal()
        maven {
            name = "GitHubPackages-common-gradle"
            url = uri("https://maven.pkg.github.com/rmarap/lastbenchcap-common-gradle")
            credentials {
                username = System.getenv("GITHUB_USERNAME") ?: System.getenv("USERNAME") ?: "github"
                password = System.getenv("GITHUB_TOKEN") ?: System.getenv("TOKEN") ?: ""
            }
        }
    }
}

// Apply the repo-management-settings plugin
plugins {
    id 'com.lastbenchcap.repo-management-settings'
}
```

#### 4. Configure build.gradle

```gradle
plugins {
    id 'com.lastbenchcap.common.gradle'
}

// Optional: Add project-specific dependencies
dependencies {
    runtimeOnly 'org.postgresql:postgresql'
}
```

## Plugin Details

### Common Gradle Plugin (`com.lastbenchcap.common.gradle`)

#### Applied Plugins
- `java-library`
- `maven-publish`
- `jacoco`
- `org.springframework.boot`
- `io.spring.dependency-management`

#### Common Dependencies
- Spring Boot starters (data-jpa, security, web, validation, aop)
- JWT libraries (jjwt-api, jjwt-impl, jjwt-jackson)
- ULID creator
- Lombok
- OpenAPI documentation
- Test dependencies (JUnit 5, Mockito, H2)

#### Configuration
- Java 21 toolchain
- GitHub Packages publishing
- JaCoCo code coverage
- Sources and Javadoc JARs
- Standardized POM metadata

### Repo Management Settings Plugin (`com.lastbenchcap.repo-management-settings`)

#### Features
- Centralizes repository configuration across all projects
- Automatically configures GitHub Packages repositories
- Prioritizes mavenLocal() for local development
- Reads repository list from file or property
- Sets `RepositoriesMode.FAIL_ON_PROJECT_REPOS` for consistency

#### Configuration Options
- `lastbenchcap.github.repos.file` - Path to file containing repository names
- `lastbenchcap.github.repos` - Comma-separated list of repository names
- `lastbenchcap.github.owner` - GitHub username/organization
- Environment variables: `GITHUB_REPOSITORY_OWNER`, `GITHUB_USERNAME`, `GITHUB_TOKEN`

## Local Development

### Using Local Plugin Versions

For local development, you can use the local version of the plugins:

```gradle
// In settings.gradle, uncomment this line:
// includeBuild '../lastbenchcap-common-gradle'

// Then remove version from build.gradle:
plugins {
    id 'com.lastbenchcap.common.gradle'  // No version needed
}
```

### Building the Plugin

```bash
cd lastbenchcap-common-gradle
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

## Project Structure

```
spikes-2025/
├── lastbenchcap-common/              # Common library
├── lastbenchcap-common-gradle/       # This plugin project
└── lastbenchcap-svc-dms/            # Example service
```

## Best Practices

1. **Always use the repo-management-settings plugin** in settings.gradle
2. **Keep lastbenchcap-repos.txt updated** with all relevant repositories
3. **Use relative paths** for includeBuild when working locally
4. **Comment out includeBuild** by default for production builds
5. **Leverage the common-gradle plugin** for consistent build configuration

## Troubleshooting

### Common Issues

1. **Repository not found**: Ensure the repository is listed in lastbenchcap-repos.txt
2. **Authentication failed**: Check GITHUB_TOKEN environment variable
3. **Plugin not found**: Verify pluginManagement repositories are configured correctly
4. **Build conflicts**: Ensure includeBuild is commented out unless needed locally

### Debug Commands

```bash
# Check available repositories
./gradlew dependencies --configuration compileClasspath

# Verify plugin resolution
./gradlew help --task :help

# Check repository configuration
./gradlew buildEnvironment
```

## Version History

- `1.0.27` - Added repo-management-settings plugin, simplified project configuration
- `1.0.26` - Optimized build script, removed unused dependencies
- `1.0.25` - Fixed plugin configuration and repository management
- `1.0.0` - Initial release with common library configuration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with multiple projects
5. Submit a pull request

## License

MIT License 