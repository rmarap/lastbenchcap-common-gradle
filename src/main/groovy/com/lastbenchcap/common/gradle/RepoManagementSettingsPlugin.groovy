package com.lastbenchcap.common.gradle

import org.gradle.api.Plugin
import org.gradle.api.initialization.Settings
import org.gradle.api.artifacts.repositories.MavenArtifactRepository
import org.gradle.api.initialization.resolve.RepositoriesMode

/**
 * Settings plugin that centralizes dependency repositories for all LastBenchCap projects.
 *
 * Reads optional property 'lastbenchcap.github.repos' (comma-separated) to know which
 * GitHub Packages repositories to add. Defaults to commonly used repos.
 */
class RepoManagementSettingsPlugin implements Plugin<Settings> {
    @Override
    void apply(Settings settings) {
        def ghOwner = System.getenv('GITHUB_REPOSITORY_OWNER')
                ?: settings.providers.gradleProperty('lastbenchcap.github.owner').orNull
                ?: settings.providers.gradleProperty('github.owner').orNull
                ?: 'rmarap'
        def reposProp = settings.providers.gradleProperty('lastbenchcap.github.repos').orNull
        def reposFileProp = settings.providers.gradleProperty('lastbenchcap.github.repos.file').orNull
                ?: System.getenv('LASTBENCHCAP_GITHUB_REPOS_FILE')
        List<String> ghRepos = []
        if (reposFileProp) {
            def reposFile = new File(reposFileProp)
            if (!reposFile.isAbsolute()) {
                reposFile = new File(settings.settingsDir, reposFileProp)
            }
            if (reposFile.exists()) {
                ghRepos = reposFile.readLines('UTF-8')
                        .collect { it.trim() }
                        .findAll { it && !it.startsWith('#') }
            }
        }
        if (ghRepos.isEmpty() && reposProp) {
            ghRepos = reposProp.split(/[\s,;]+/)
                    .collect { it.trim() }
                    .findAll { !it.isEmpty() }
        }

        settings.dependencyResolutionManagement {
            repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
            repositories {
                // Add GitHub Packages repos for internal artifacts
                if (!ghRepos.isEmpty()) {
                    ghRepos.each { String repoName ->
                        maven { MavenArtifactRepository r ->
                            r.name = "GitHubPackages-${repoName}"
                            r.setUrl(settings.providers.provider { "https://maven.pkg.github.com/${ghOwner}/${repoName}" })
                            r.credentials { cred ->
                                cred.setUsername(System.getenv('GITHUB_USERNAME') ?: System.getenv('USERNAME') ?: 'github')
                                cred.setPassword(System.getenv('GITHUB_TOKEN') ?: System.getenv('TOKEN') ?: '')
                            }
                            r.content { content ->
                                content.includeGroup('com.lastbenchcap')
                            }
                        }
                    }
                }

                // Local and public repos
                mavenLocal()
                mavenCentral()
            }
        }
    }
}


