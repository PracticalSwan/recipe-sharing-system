# Skills Activation Audit - 2026-02-13

## Context
- User requested a quality pass on imported skill activation/non-activation conditions.
- Target directory: `C:\Users\LOQ\.codex\imported\skills`.

## Decisions
- Use explicit activation and non-activation condition blocks as the primary acceptance check.
- Repair malformed top-of-file condition sections instead of rewriting full skill bodies.
- Fix encoding artifacts (mojibake) only in files with clear corruption markers (`â`, `Ã`, `Â`).

## Changes Applied
- Updated activation/non-activation section structure in:
  - `devops-tooling/SKILL.md`
  - `legacy-circuit-mockups/SKILL.md`
  - `microsoft-development/SKILL.md`
  - `powerbi-modeling/SKILL.md`
  - `office-documents/SKILL.md`
- Repaired mojibake encoding in:
  - `azure-integrations/SKILL.md`
  - `canvas-design/SKILL.md`
  - `devops-tooling/SKILL.md`
  - `legacy-circuit-mockups/SKILL.md`
  - `microsoft-development/SKILL.md`
  - `mongodb-mongoose/SKILL.md`
  - `nestjs/SKILL.md`
  - `office-documents/SKILL.md`
  - `stitch-design/SKILL.md`

## Validation
- Confirmed no remaining empty `When to Use This Skill` sections followed immediately by non-activation.
- Confirmed no remaining `â`, `Ã`, `Â` markers in imported `SKILL.md` files.
- Confirmed all skill files include both activation and non-activation sections.

## Next Steps
- Optional: run a style-normalization pass to standardize heading names across all skills (`When to Use This Skill` vs `Activation Conditions`).
