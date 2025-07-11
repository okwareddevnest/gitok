# GitOK Scripts

This directory contains utility scripts for managing GitOK versions and releases.

## 📋 Available Scripts

### `bump-version.sh`
**Manual version management and release preparation**

```bash
./scripts/bump-version.sh [major|minor|patch]
```

**What it does:**
- ✅ Validates git repository state
- ✅ Bumps version in `VERSION` file and `.gitok.sh`
- ✅ Auto-generates changelog from git commits
- ✅ Creates git commit and tag
- ✅ Provides push instructions

**Examples:**
```bash
./scripts/bump-version.sh patch  # 1.0.0 → 1.0.1
./scripts/bump-version.sh minor  # 1.0.1 → 1.1.0  
./scripts/bump-version.sh major  # 1.1.0 → 2.0.0
```

### `generate-changelog.sh`
**Dynamic changelog and release notes generation**

```bash
./scripts/generate-changelog.sh [changelog|release-notes] [version]
```

**What it does:**
- 📝 Parses git commits since last tag
- 🏷️ Categorizes commits using conventional commit patterns
- ✨ Generates beautiful changelog sections
- 🚀 Creates GitHub-ready release notes

**Commit Categories:**
- **✨ Added** - New features (`feat:`, `add`, `new`, `implement`)
- **🚀 Improved** - Enhancements (`improve`, `enhance`, `optimize`, `refactor`)
- **🐛 Fixed** - Bug fixes (`fix:`, `bug:`, `resolve`, `correct`)
- **📚 Documentation** - Docs (`docs:`, `document`, `readme`)
- **🔧 Technical** - Dev stuff (`chore:`, `build:`, `ci:`, `test:`)
- **⚠️ BREAKING** - Breaking changes (commits with `!` or `breaking`)

**Examples:**
```bash
# Update CHANGELOG.md for current version
./scripts/generate-changelog.sh changelog

# Generate GitHub release notes for v1.2.0
./scripts/generate-changelog.sh release-notes 1.2.0
```

## 🔄 Automated Workflows

### CI/CD Integration
The scripts are used by GitHub Actions for CI/CD:

1. **On manual release trigger** → Bumps version → Generates changelog → Creates release
2. **On `[release]` commit** → Auto-triggers release workflow
3. **On version bump** → Auto-generates release notes from commits

### Conventional Commits
For best results, use conventional commit messages:

```bash
feat: add new git alias for interactive rebase
fix: resolve issue with unpush confirmation
docs: update README with new installation steps
improve: enhance error handling in push functions
chore: update CI/CD pipeline configuration
```

## 🛠️ Manual Release Process

1. **Make your changes and commit them**
2. **Run version bump script:**
   ```bash
   ./scripts/bump-version.sh patch
   ```
3. **Push changes and tags:**
   ```bash
   git push origin main --tags
   ```
4. **GitHub Actions will create the release!**

## 📊 How It Works

### Version Bumping
1. Reads current version from `VERSION` file
2. Increments based on semver rules
3. Updates version in `.gitok.sh` script
4. Generates changelog from git commits
5. Creates commit and git tag

### Changelog Generation
1. Gets all commits since last git tag
2. Categorizes commits by type (feat, fix, docs, etc.)
3. Cleans up commit messages (removes prefixes)
4. Generates markdown sections with emojis
5. Updates `CHANGELOG.md` or outputs release notes

### Release Notes
- **GitHub-ready format** with installation instructions
- **Categorized changes** for easy scanning
- **Direct links** to full changelog comparisons
- **Installation/update commands** included

---

💡 **Pro Tip:** Use descriptive commit messages for better changelogs! 