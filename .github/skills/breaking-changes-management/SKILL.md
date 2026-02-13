---
name: breaking-changes-management
description: Breaking changes documentation, migration guides, deprecation process, and versioning. Use when introducing breaking API changes, creating migration guides, deprecating features, updating changelogs, managing major version releases, or documenting version transitions. Triggered by keywords like breaking changes, migration guide, deprecation notice, version upgrade, changelog update, breaking API modification.
license: Complete terms in LICENSE.txt
---

# Breaking Changes Management

## Skill Paths

- Workspace skills: `.github/skills/`
- Global skills: `C:/Users/LOQ/.copilot/skills/`

## Activation Conditions

Use this skill when:
- Introducing breaking API changes
- Creating migration guides
- Deprecating features with timeline
- Updating CHANGELOG.md for major versions
- Managing version transitions

## Non-Activation Conditions

**Do NOT activate this skill when:**
- Changes are backward compatible and don't affect existing functionality
- Updates are minor version changes without breaking changes
- User needs to update documentation for features without API changes
- Task involves simple bug fixes that don't alter functionality
- Updating feature documentation without version transitions
- Changes are internal implementation details not exposed to users

## Breaking Change Documentation

**When breaking API changes occur:**
- Document what changed
- Provide before/after examples
- Include step-by-step migration instructions
- Update CHANGELOG.md with BREAKING prefix

## Deprecation Process

See [Deprecation Procedures](./references/deprecation.md) for:
- marking deprecated features
- suggesting alternative approaches
- creating migration guides
- updating changelog with deprecation notice
- setting timeline for removal

## Migration Guides

**Create migration guides when:**

1. **Breaking API changes occur**: Document what changed, provide before/after examples, include step-by-step migration instructions

2. **Major version updates**: List all breaking changes, provide upgrade checklist, include common migration issues and solutions

3. **Deprecating features**: Mark deprecated features clearly, suggest alternative approaches, include timeline for removal

## Changelog Format

```markdown
## [Version] - YYYY-MM-DD

### Added
- New feature description with reference to PR/issue

### Changed
- **BREAKING**: Description of breaking change
- Other changes

### Fixed
- Bug fix description
```

## Review Checklist

- [ ] Breaking changes clearly documented
- [ ] Migration guide created if needed
- [ ] Deprecated features marked with alternative suggestions
- [ ] Removal timeline specified
- [ ] ChangeLog updated with BREAKING prefix
- [ ] Before/after examples provided
