# Docker Setup for Perl Advent Calendar

This document describes how to use Docker to build and preview the Perl Advent Calendar site locally or in CI.

## Overview

The Docker setup provides a containerized environment with all dependencies pre-installed, making it easy to:
- Preview articles locally without installing Perl dependencies
- Generate screenshots in CI
- Ensure consistent builds across different environments

## Architecture

### Services

The `docker-compose.yml` defines two services:

1. **perl-advent** - Builds the static site
2. **perl-advent-server** - Serves the built site on port 7007

### Key Components

- **Dockerfile**: Multi-stage build that installs Perl 5.40, system dependencies (vim, git), and all required CPAN modules
- **docker-compose.yml**: Orchestrates the build and server services
- **Named volume**: `build-output` volume stores the generated site and is shared between services

### Volume Strategy

The setup uses two types of mounts:

1. **Bind mount** (`.:/app`): Mounts your local source code into the container so changes are immediately available
2. **Named volume** (`build-output:/app/out`): Isolates the build output directory

This approach allows `rm -rf out` to run safely inside the container without deleting files on your host filesystem. The named volume "shadows" the `out/` directory from the bind mount.

## Basic Usage

### Build the Docker Image

```bash
docker compose build
```

This creates the `perl-advent:latest` image with all dependencies installed. You only need to rebuild if the Dockerfile changes.

### Build the Site

```bash
docker compose run --rm perl-advent
```

This runs the build process and generates the static site in the `build-output` volume.

### Preview the Site

```bash
docker compose up perl-advent-server
```

Then visit http://localhost:7007 in your browser.

Press `Ctrl+C` to stop the server.

### Build and Serve in One Command

```bash
docker compose up
```

This builds the site and starts the server. The site will be available at http://localhost:7007.

## Advanced Usage

### Build a Single Year

For faster iteration when testing:

```bash
docker compose run --rm perl-advent bash -c "bash script/build-site.sh --single-year 2025"
```

### Simulate a Specific Date

Useful for testing calendar behavior:

```bash
docker compose run --rm perl-advent bash -c "bash script/build-site.sh --today 2025-12-15"
```

### Access Built Files Locally

The built files are stored in a Docker volume, not directly on your filesystem. To access them:

```bash
# Copy entire build output to local directory
docker compose run --rm perl-advent cp -r /app/out /app/out-local

# Then access files at ./out-local/
```

Alternatively, temporarily modify `docker-compose.yml` to use a bind mount for the server:

```yaml
perl-advent-server:
  volumes:
    - ./out:/app/out  # Instead of build-output:/app/out
```

### Run Commands Inside the Container

```bash
# Get a shell
docker compose run --rm perl-advent bash

# Run tests
docker compose run --rm perl-advent prove -lr t/

# Check a specific article
docker compose run --rm perl-advent perl t/article_pod.t 2025/incoming/your-article.pod
```

### Clean Up

```bash
# Remove the build output volume
docker compose down -v

# Remove the Docker image
docker rmi perl-advent:latest
```

## CI Usage

Both the `test.yml` and `build.yml` workflows use Docker Compose to ensure consistency between local development and CI.

### Docker Layer Caching

Both workflows use GitHub Actions cache (`type=gha`) to share Docker layers between workflow runs and across different workflows. This means:

- The first workflow run builds all layers (~5 minutes)
- Subsequent runs reuse cached layers (~30 seconds)
- Different workflows (test vs build) share the same cache
- The image only rebuilds when the Dockerfile or dependencies change

### Test Workflow

```yaml
- uses: actions/checkout@v6
  with:
    submodules: true
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v3
- name: Build Docker image
  uses: docker/bake-action@v6
  with:
    files: docker-compose.yml
    load: true
    set: |
      *.cache-from=type=gha
      *.cache-to=type=gha,mode=max
- name: Run tests
  run: docker compose run --rm perl-advent prove -lr t
```

### Build and Deploy Workflow

```yaml
- uses: actions/checkout@v6
  with:
    submodules: true
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v3
- name: Build Docker image
  uses: docker/bake-action@v6
  with:
    files: docker-compose.yml
    load: true
    set: |
      *.cache-from=type=gha
      *.cache-to=type=gha,mode=max
- name: Build articles
  run: docker compose run --rm perl-advent
- name: Copy built site from Docker volume
  run: docker compose run --rm perl-advent cp -r /app/out /app/out-ci
- name: Move built site to host
  run: mv out-ci out
```

The key difference in CI is that we need to copy the built site from the Docker volume to the host filesystem so GitHub Actions can upload it as an artifact.

### Screenshot Generation

If you need to generate screenshots in CI:

```yaml
- name: Start web server
  run: docker compose up -d perl-advent-server
- name: Generate screenshot
  run: |
    # Your screenshot commands here (e.g., using Playwright)
- name: Stop server
  run: docker compose down
```

Since CI environments are ephemeral, the named volume will be automatically cleaned up after each run.

## Troubleshooting

### Port 7007 Already in Use

If you get a port conflict error:

```bash
# Check what's using the port
lsof -i :7007

# Either stop that process, or change the port in docker-compose.yml:
ports:
  - '8080:7007'  # Map to different local port
```

### Build Fails with Git Errors

The Dockerfile handles git worktree issues automatically by reinitializing the repository inside the container. If you still see git-related errors, try rebuilding from scratch:

```bash
docker compose build --no-cache
```

### Container Can't Access Local Files

Make sure you're running commands from the repository root (where `docker-compose.yml` is located). The `.:/app` mount assumes you're in the correct directory.

### Out of Disk Space

Docker images and volumes can consume significant disk space. To clean up:

```bash
# Remove unused images and volumes
docker system prune -a --volumes

# Or just remove this project's resources
docker compose down -v
docker rmi perl-advent:latest
```

## Development Notes

### Why Use a Named Volume for /app/out?

The repository source code is mounted via `.:/app`, which makes local changes immediately available in the container. However, this means any modifications to files in `/app/out` inside the container would also affect your local filesystem.

The `build-site.sh` script runs `rm -rf out` to ensure clean builds. Without the named volume, this would delete your local `out/` directory.

By mounting a named volume at `/app/out`, we "shadow" that directory. Changes to `/app/out` inside the container only affect the volume, not your host filesystem.

### Dockerfile Layer Optimization

The Dockerfile is optimized for fast rebuilds using Docker's layer caching:

```dockerfile
# Layer 1-3: Base image and system packages (rarely change)
FROM perldocker/perl-tester:5.40
RUN apt-get update && apt-get install -y vim git
WORKDIR /app

# Layer 4-5: Copy only dependency files (change when adding/updating deps)
COPY cpanfile ./
COPY inc/ ./inc/

# Layer 6-11: Install all dependencies (cache invalidates only when deps change)
RUN cpm install -g --cpanfile=cpanfile --with-develop
# ... install forked modules ...

# Layer 12-13: Copy application code (invalidates on any source change)
COPY . .
```

**Build time breakdown:**
- **Dependency layers (6-11)**: ~4 minutes (cached unless cpanfile/inc/ changes)
- **Application layer (12-13)**: ~1 second (invalidates on any article/config change)

This means editing articles or configuration files triggers only a ~1 second rebuild, not a full 5-minute dependency reinstall.

### Dependency Installation

The Dockerfile installs dependencies in this order:

1. **System packages**: vim, git
2. **vim-perl**: Perl syntax highlighting for vim (required by Text::VimColor)
3. **CPAN modules**: From cpanfile
4. **Forked modules**: Custom versions from `inc/` directory
   - WWW-AdventCalendar
   - Pod-Elemental-Transformer-SynHi
   - PPI-HTML

Each step is a separate Docker layer, so rebuilds are fast if only later steps change.

### Git Repository Initialization

The Dockerfile includes this workaround:

```dockerfile
RUN rm -rf .git inc/*/.git && \
    git init && \
    git config user.email "docker@build" && \
    git config user.name "Docker Build" && \
    git add . && \
    git commit -m "Initial commit for build"
```

This is necessary because:
- The repository uses git worktrees
- `COPY . .` copies `.git` files that contain worktree pointers to paths outside the container
- Dist::Zilla (used to build the forked modules) requires a valid git repository
- Solution: Remove broken git references and initialize a fresh repository

This adds ~2 seconds to build time but is required for the build to succeed.
