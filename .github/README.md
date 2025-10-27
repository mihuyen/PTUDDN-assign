# CI/CD Pipeline Documentation

This repository uses GitHub Actions for continuous integration and deployment across multiple Maven modules.

## 🏗️ Project Structure

The repository contains three main modules:
- **docker**: Spring Boot application with MySQL integration (Java 21)
- **sso**: Spring Boot SSO application with OAuth2 (Java 21)  
- **k8s**: Kubernetes demo application with monitoring (Java 22)

## 🚀 Workflows

### 1. Multi-Module CI/CD Pipeline (`.github/workflows/ci.yml`)

**Triggers:**
- Push to `main`, `develop`, or `test-ci-trigger` branches
- Pull requests to `main` or `develop` branches

**Features:**
- **Smart change detection**: Only builds modules that have changed
- **Parallel testing**: Tests all affected modules simultaneously
- **Multi-architecture Docker builds**: Supports AMD64 and ARM64
- **Security scanning**: Trivy vulnerability scanning for Docker images
- **Artifact management**: Uploads JAR files and test reports

**Jobs:**
1. `detect-changes`: Identifies which modules have changed
2. `test-{module}`: Runs tests for each affected module
3. `build-{module}`: Builds JAR files for each affected module
4. `docker-{module}`: Builds and pushes Docker images
5. `security-scan`: Scans Docker images for vulnerabilities
6. `notification`: Sends status notifications

### 2. Release Pipeline (`.github/workflows/release.yml`)

**Triggers:**
- Git tags matching `v*.*.*` pattern
- Manual workflow dispatch

**Features:**
- **Version validation**: Ensures proper semantic versioning
- **Multi-module testing**: Tests all modules before release
- **Release Docker images**: Builds production images with multiple tags
- **Security scanning**: Scans release images
- **GitHub releases**: Creates releases with changelog and artifacts

**Process:**
1. Validate tag format
2. Test all modules
3. Build all modules
4. Create release Docker images
5. Security scan release images
6. Create GitHub release with artifacts

### 3. Security Scanning (`.github/workflows/security.yml`)

**Triggers:**
- Weekly schedule (Mondays at 2 AM)
- Manual workflow dispatch
- Push to `main` branch

**Security Checks:**
- **Dependency scanning**: OWASP dependency check for Maven dependencies
- **Code analysis**: CodeQL security analysis
- **Secret scanning**: TruffleHog for exposed secrets
- **License compliance**: License check for all dependencies
- **Docker security**: Trivy and Grype vulnerability scanning
- **Reporting**: Consolidated security reports

## 🔧 Configuration

### Required Secrets

Set these in your repository settings → Secrets and variables → Actions:

```
GITHUB_TOKEN (automatically provided)
SLACK_WEBHOOK_URL (optional - for notifications)
SONAR_TOKEN (optional - for SonarCloud analysis)
KUBE_CONFIG_STAGING (optional - for staging deployments)
KUBE_CONFIG_PRODUCTION (optional - for production deployments)
```

### Environment Variables

The workflows use these environment variables:
- `REGISTRY`: Container registry (default: ghcr.io)
- `IMAGE_NAME`: Docker image name (default: repository name)

## 📦 Dependabot Configuration

Automatic dependency updates are configured in `.github/dependabot.yml`:

- **Maven dependencies**: Weekly updates for all modules
- **Docker base images**: Weekly updates
- **GitHub Actions**: Weekly updates
- **Security updates**: Immediate updates for vulnerabilities

## 🏷️ Labeling Strategy

Issues and PRs are automatically labeled:
- `dependencies`: Dependency updates
- `bug`: Bug reports
- `enhancement`: Feature requests
- `security`: Security-related issues
- `{module}-module`: Module-specific changes

## 📋 Branch Protection

Recommended branch protection rules for `main`:

```yaml
required_status_checks:
  strict: true
  contexts:
    - "Test Docker Module"
    - "Test SSO Module" 
    - "Test K8s Module"
    - "Build Docker Module"
    - "Build SSO Module"
    - "Build K8s Module"
enforce_admins: true
require_linear_history: true
required_pull_request_reviews:
  required_approving_review_count: 1
  dismiss_stale_reviews: true
```

## 🚀 Docker Images

Images are published to GitHub Container Registry:

```bash
# Pull latest images
docker pull ghcr.io/mihuyen/ptuddn-assign/docker:latest
docker pull ghcr.io/mihuyen/ptuddn-assign/k8s:latest

# Pull specific version
docker pull ghcr.io/mihuyen/ptuddn-assign/docker:v1.0.0
docker pull ghcr.io/mihuyen/ptuddn-assign/k8s:v1.0.0
```

## 📈 Monitoring & Notifications

### Slack Integration (Optional)

To enable Slack notifications:

1. Create a Slack webhook URL
2. Add it as `SLACK_WEBHOOK_URL` secret
3. Notifications will be sent to:
   - `#ci-cd`: CI/CD pipeline status
   - `#releases`: Release notifications  
   - `#security-alerts`: Security scan failures

### GitHub Notifications

- **Status checks**: Required checks must pass before merging
- **Security alerts**: Automated security vulnerability notifications
- **Dependency updates**: PR notifications for Dependabot updates

## 🎯 Best Practices

### For Developers

1. **Feature branches**: Use descriptive branch names
2. **Commit messages**: Follow conventional commit format
3. **Testing**: Ensure tests pass locally before pushing
4. **Security**: Never commit secrets or sensitive data

### For Releases

1. **Semantic versioning**: Use `v1.0.0` format for tags
2. **Changelog**: Releases automatically include changelog
3. **Testing**: All tests must pass before release
4. **Security**: Security scans are mandatory for releases

### For Dependencies

1. **Regular updates**: Review Dependabot PRs weekly
2. **Security patches**: Apply security updates immediately  
3. **Testing**: Test dependency updates thoroughly
4. **Breaking changes**: Check for breaking changes in major updates

## 🔍 Troubleshooting

### Common Issues

**Build failures:**
```bash
# Check Java version compatibility
# Docker: Java 21
# SSO: Java 21
# K8s: Java 22
```

**Docker build failures:**
```bash
# Ensure Dockerfile exists in module directory
# Check base image availability
# Verify build context
```

**Test failures:**
```bash
# Run tests locally first
cd {module} && mvn clean test
```

**Security scan failures:**
```bash
# Review vulnerability reports
# Update affected dependencies
# Apply security patches
```

### Getting Help

1. Check workflow logs in GitHub Actions tab
2. Review test reports and artifacts
3. Check security scan results
4. Create an issue using provided templates

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Maven Documentation](https://maven.apache.org/guides/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)