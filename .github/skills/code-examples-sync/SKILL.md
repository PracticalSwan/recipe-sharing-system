---
name: code-examples-sync
description: Code example synchronization, verification, and update patterns. Use when function signatures change, API interfaces are modified, best practices evolve, or examples need updates. Triggers on code example outdated, example syntax errors, updating imports, verifying documentation snippets, and maintaining example consistency across docs.
license: Complete terms in LICENSE.txt
---

# Code Example Synchronization

Maintain code examples in documentation that stay synchronized with actual code.

## Skill Paths

- Workspace skills: `.github/skills/`
- Global skills: `C:/Users/LOQ/.copilot/skills/`

## Activation Conditions

Use this skill when:
- Function signatures or parameters change
- API interfaces are modified
- Best practices evolve (deprecated patterns emerge)
- Code examples become outdated
- Imports or dependencies change

## Non-Activation Conditions

**Do NOT activate this skill when:**
- Documentation updates don't involve code examples or snippets
- User asks for general documentation review without code validation
- Task involves improving writing style or grammar without code elements
- Documentation changes are purely conceptual without implementation details
- User needs to update only README files without code examples
- Writing marketing material or descriptive text without technical examples

## Verification Checks

See [Code Example Verification](./references/verification.md) for:
- Checking examples compile/run correctly
- Verifying imports are up to date
- Testing example output matches documentation
- Ensuring consistent syntax across examples

## Update Patterns

When code changes affect examples:

1. **Function signature changes**: Update all snippets using the function, verify examples compile, update imports if needed

2. **API interface changes**: Update request/response examples, revise client code examples, update SDK usage examples

3. **Best practice evolution**: Replace outdated patterns, update to current recommended approaches, add deprecation notices for old patterns

## Quality Checklist

- [ ] All code examples compile/run successfully
- [ ] Imports and dependencies are current
- [ ] Output matches documented results
- [ ] Syntax is consistent across language
- [ ] Error handling is demonstrated where applicable
