package com.lastbenchcap.common.gradle

import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.plugins.JavaLibraryPlugin
import org.gradle.api.publish.maven.MavenPublication
import org.gradle.api.publish.maven.plugins.MavenPublishPlugin
import org.gradle.testing.jacoco.plugins.JacocoPlugin
import org.gradle.api.tasks.bundling.Jar
import org.gradle.jvm.toolchain.JavaLanguageVersion

class CommonLibraryPlugin implements Plugin<Project> {
    
    @Override
    void apply(Project project) {
        // Apply base plugins
        project.plugins.apply(JavaLibraryPlugin)
        project.plugins.apply(MavenPublishPlugin)
        project.plugins.apply(JacocoPlugin)
        project.plugins.apply('org.springframework.boot')
        project.plugins.apply('io.spring.dependency-management')
        
        // Configure the project
        configureProject(project)
        configureDependencies(project)
        configureTesting(project)
        configurePublishing(project)
        configureJaCoCo(project)
    }
    
    private void configureProject(Project project) {
        // Library configuration from gradle.properties
        project.group = project.findProperty('library.group') ?: 'com.lastbenchcap'
        project.version = project.findProperty('library.version') ?: '1.0.0'
        project.base.archivesName = project.findProperty('library.artifactId') ?: project.name
        
        // Version management
        project.ext {
            libraryVersion = project.findProperty('library.version') ?: project.version
            githubOwner = System.getenv('GITHUB_REPOSITORY_OWNER') ?: project.findProperty('github.owner') ?: 'rmarap'
            githubRepo = System.getenv('GITHUB_REPOSITORY')?.split('/')?.last() ?: project.findProperty('github.repo') ?: project.name
            libraryName = project.findProperty('library.name') ?: "${project.name} Library"
            libraryDescription = project.findProperty('library.description') ?: "A shared library for ${project.name}"
        }
        
        // Java configuration
        def javaVersion = project.findProperty('java.version') ?: '21'
        project.java {
            toolchain {
                languageVersion = JavaLanguageVersion.of(Integer.parseInt(javaVersion.toString()))
            }
        }
        
        // Disable boot jar for library
        project.bootJar {
            enabled = false
        }
        
        project.jar {
            enabled = true
            from project.sourceSets.test.output
        }
        
        // Create sources JAR
        tasks.register('sourcesJar', Jar) {
            from project.sourceSets.main.allSource
            archiveClassifier = 'sources'
        }
        
        // Create javadoc JAR
        tasks.register('javadocJar', Jar) {
            from project.javadoc
            archiveClassifier = 'javadoc'
        }
        
        // Repositories
        project.repositories {
            mavenCentral()
        }
    }
    
    private void configureDependencies(Project project) {
        project.dependencies {
            // Spring Boot dependencies
            implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
            implementation 'org.springframework.boot:spring-boot-starter-security'
            implementation 'org.springframework.boot:spring-boot-starter-web'
            implementation 'org.springframework.boot:spring-boot-starter-validation'
            implementation 'org.springframework.boot:spring-boot-starter-aop'
            
            // External dependencies
            api 'com.github.f4b6a3:ulid-creator:5.1.0'
            api 'io.jsonwebtoken:jjwt-api:0.12.5'
            runtimeOnly 'io.jsonwebtoken:jjwt-impl:0.12.5'
            runtimeOnly 'io.jsonwebtoken:jjwt-jackson:0.12.5'
            api 'org.springdoc:springdoc-openapi-starter-webmvc-ui:2.3.0'
            compileOnly 'org.projectlombok:lombok'
            annotationProcessor 'org.projectlombok:lombok'
            
            // Test dependencies - made api so consuming microservices can use test classes
            api 'org.springframework.boot:spring-boot-starter-test'
            api 'org.springframework.security:spring-security-test'
            api 'com.h2database:h2'
            api 'org.mockito:mockito-inline:5.2.0'
            
            // Also add as testImplementation for test runtime
            testImplementation 'org.springframework.boot:spring-boot-starter-test'
            testImplementation 'org.springframework.security:spring-security-test'
            testImplementation 'com.h2database:h2'
            testImplementation 'org.mockito:mockito-inline:5.2.0'
            
            // Explicit JUnit Platform dependencies
            testImplementation 'org.junit.jupiter:junit-jupiter-api:5.10.0'
            testImplementation 'org.junit.jupiter:junit-jupiter-engine:5.10.0'
            testImplementation 'org.junit.platform:junit-platform-launcher:1.10.0'
        }
    }
    
    private void configureTesting(Project project) {
        project.test {
            useJUnitPlatform()
            testLogging {
                events "passed", "skipped", "failed"
            }
        }
    }
    
    private void configurePublishing(Project project) {
        project.publishing {
            publications {
                mavenJava(MavenPublication) {
                    from project.components.java
                    artifactId = project.findProperty('library.artifactId') ?: project.name
                    version = project.libraryVersion
                    
                    artifact project.sourcesJar
                    artifact project.javadocJar
                    
                    pom {
                        name = project.libraryName
                        description = project.libraryDescription
                        url = "https://github.com/${project.githubOwner}/${project.githubRepo}"
                        licenses {
                            license {
                                name = project.findProperty('license.name') ?: 'MIT License'
                                url = project.findProperty('license.url') ?: 'https://opensource.org/licenses/MIT'
                            }
                        }
                        developers {
                            developer {
                                id = project.findProperty('developer.id') ?: project.githubOwner
                                name = project.findProperty('developer.name') ?: 'LastBenchCap Team'
                                email = project.findProperty('developer.email') ?: 'team@lastbenchcap.com'
                            }
                        }
                        scm {
                            connection = "scm:git:git://github.com/${project.githubOwner}/${project.githubRepo}.git"
                            developerConnection = "scm:git:ssh://github.com/${project.githubOwner}/${project.githubRepo}.git"
                            url = "https://github.com/${project.githubOwner}/${project.githubRepo}"
                        }
                    }
                }
            }
            repositories {
                maven {
                    name = "GitHubPackages"
                    url = "https://maven.pkg.github.com/${project.githubOwner}/${project.githubRepo}"
                    credentials {
                        username = project.findProperty("gpr.user") ?: System.getenv("GITHUB_USERNAME") ?: System.getenv("USERNAME") ?: "github"
                        password = project.findProperty("gpr.key") ?: System.getenv("GITHUB_TOKEN") ?: System.getenv("TOKEN") ?: ""
                    }
                }
            }
        }
    }
    
    private void configureJaCoCo(Project project) {
        project.jacoco {
            toolVersion = "0.8.11"
        }
        
        project.test {
            finalizedBy project.jacocoTestReport
        }
        
        project.jacocoTestReport {
            dependsOn project.test
            reports {
                xml.required = true
                csv.required = true
                html.outputLocation = project.layout.buildDirectory.dir('jacocoHtml')
            }
        }
    }
} 