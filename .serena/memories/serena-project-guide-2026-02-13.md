# Serena Usage Guide - Updated for Recipe Sharing System

**Updated:** February 13, 2026
**Project:** CSX3006 Recipe Sharing System
**Status:** Serena-enabled with 14 active memories

---

## Project-Specific Serena Configuration

This guide extends the general Serena usage (SKILL.md) with project-specific adjustments for CSX3006 Recipe Sharing System.

### Current Memory Structure

As of February 13, 2026, the project has 14 memories:

**Core Project Memories:**
- `project-overview` - Basic project information and technology stack
- `csx3006-database-project-updates` - Primary project status (v2.0 plan, 38% complete)
- `csx3006-sql-fixes-2026-02-13` - SQL script corrections documentation

**Feature-Specific Memories:**
- `recipe-features` - Recipe CRUD, search, reviews, likes/favorites logic
- `admin-features` - Approval workflow, user management, activity logs
- `storage-data-model` - LocalStorage data structure (pre-database)
- `auth-context` - Authentication flow and session management

**Implementation Memories:**
- `database-integration-implementation-plan-task` - 138-task implementation plan (v2.0)
- `routing-layouts` - Route configuration and page layouts
- `ui-components-and-styling` - Component library and Tailwind v4 conventions

**Tracking Memories:**
- `recent-work-summary-2026-02-13` - Latest session work log
- `setup-guide-update-2026-02-13` - Setup guide revisions

**Notion Integration:**
- `notion-implementation-tracking` - Notion page creation/memory sync
- `notion-sql-docs` - Notion SQL documentation updates

---

## Modified Onboarding Workflow for This Project

### Standard Onboarding (Already Complete)

1. ✅ Checked onboarding status
2. ✅ Read Serena Instructions Manual
3. ✅ Initialized project memory system
4. ✅ Created initial project memories

### Session-Start Pattern (Current Practice)

**Every session start:**
1. ✅ Check onboarding with `check_onboarding_performed`
2. ✅ List memories with `list_memories` to see available context
3. ✅ Read critical memories:
   - `csx3006-database-project-updates` (project status)
   - `active-context` (if available, or `csx3006-database-project-updates` for recent work)
   - `recent-work-summary-*` (latest session context)

**Why this pattern works for this project:**
- The project is in **Phase 4 (0% complete)** with 85 tasks remaining
- Database is complete (Phases 1-3 done)
- Context shifts quickly as backend development progresses
- Need to track specific technical decisions (e.g., table names, singular conventions)

---

## Memory Management Adjustments

### When to Update Memories (Project-Specific)

**Update `csx3006-database-project-updates` when:**
- Completing an entire phase (1-6)
- Changing implementation plan (v2.0 → v2.1?)
- Moving past major milestones (e.g., "Backend API complete")
- Fixing database schema or SQL scripts
- Making authentication/architecture decisions

**Create new specific memories when:**
- Fixing SQL scripts (e.g., `csx3006-sql-fixes-2026-02-13`)
- Updating user guides (e.g., `setup-guide-update-2026-02-13`)
- Documenting a complex feature (e.g., `auth-features`, `recipe-features`)
- Analyzing plan changes

**Create session summary memories when:**
- Ending a substantial work session
- Making significant progress on multiple tasks
- Need to preserve context between AI agent sessions
- Pattern: `recent-work-summary-{YYYY-MM-DD}`

### Memory Organization Patterns

**Don't use task memories for this project:**
- The project uses `plan/upgrade-database-integration-1.md` for task tracking
- 138 tasks are managed in the plan file (TASK-001 to TASK-138)
- Keep memories for:
  - Status snapshots (phase completion)
  - Technical decisions
  - Feature specifications
  - Bug fixes and corrections

---

## Project-Specific Best Practices

### Code Structure Patterns

**Database Scripts:**
- All SQL scripts are in `database/` folder
- Schemas defined in `02_create_tables.sql` (authoritative)
- Naming conventions: singular tables, `id` PKs, snake_case columns
- When fixing issues, update `csx3006-sql-fixes-{date}.md` memory

**Backend (Future - Phase 4):**
- Plain PHP (no frameworks, no Composer)
- Structure: `backend/{config, helpers, api}/`
- Routing: Each `api/*.php` handles method via `$_SERVER['REQUEST_METHOD']`
- Sessions: Server-side in `session` table, HttpOnly cookies

**Frontend (Current - Active):**
- React 19 + Vite + Tailwind v4
- Auth: Session-based (previously localStorage)
- API: Native `fetch()` with `credentials: 'include'`
- Components: In `src/components/`, pages in `src/pages/`

**Documentation:**
- Guides in `guides/` folder (already updated)
- Plan in `plan/` folder (v2.0, 138 tasks)
- Serena memories in `.serena/memories/`

### Symbol Navigation for This Project

**When to use:**
- Navigating React components in `src/pages/` or `src/components/`
- Exploring PHP backend after Phase 4 implementation
- Understanding component props and hooks

**Current limitations:**
- Backend (PHP) not yet created — symbol navigation limited to frontend
- Use `get_symbols_overview` on TypeScript/React files
- Use `search_for_pattern` for SQL script content (PHP not indexed yet)

### Memory Updates for Project Events

**After database schema changes:**
Update `csx3006-database-project-updates` with:
- Table additions/removals
- Column changes with rationale
- FK constraints added
- New triggers or procedures

**After guide/documentation updates:**
Create specific memory with name pattern:
- `{feature}-update-{date}.md` e.g., `setup-guide-update-2026-02-13`
- Include summary of changes
- Reference related plan tasks if applicable

**After bug fixes:**
Create or update memories:
- Include issue description
- Document root cause analysis
- Record fix implemented
- Note any related files changed

---

## Work Session Example (February 13, 2026)

### Session Started
1. Check onboarding → ✅ Already done
2. List memories → 14 available
3. Read critical memories:
   - `csx3006-database-project-updates` (38% complete, Phase 4 pending)
   - `csx3006-sql-fixes-2026-02-13` (recent SQL fixes)
   - `recent-work-summary-2026-02-13` (previous session)

### Tasks Completed
1. Identified SETUP_GUIDE_PHPMYADMIN.md inconsistencies:
   - Database name: `recipe_sharing_db` → `cookhub`
   - Table names: plural → singular throughout
   - User accounts: 10 → 12 (matching seed data)
   - Backend structure: Update to plan v2.0 (flat PHP)
   - Dependencies: Remove axios, use native fetch()

2. Updated SETUP_GUIDE_PHPMYADMIN.md (60+ sections modified):
   - Corrected all database/table references
   - Updated project status section
   - Added future enhancement notes (TASK-117)
   - Fixed all troubleshooting steps

3. Created `setup-guide-update-2026-02-13.md` memory:
   - Detailed all changes for traceability
   - Linked to related memories (SQL fixes, plan documents)

### Memories Updated
- Create: `setup-guide-update-2026-02-13.md`
- No modifications to existing memories (documented in new memory instead)

### Session Documentation
Created comprehensive update memory to ensure future sessions understand:
- Why the setup guide was updated
- What specific changes were made
- Which authoritative sources were used (SQL scripts, plan v2.0)

---

## Current Serena Configuration

### Active Memories (14)

| Memory | Purpose | Last Updated |
|---------|---------|---------------|
| `project-overview` | Basic project info | Initial |
| `csx3006-database-project-updates` | **Primary status memory** | 2026-02-13 |
| `csx3006-sql-fixes-2026-02-13` | SQL script corrections | 2026-02-13 |
| `database-integration-implementation-plan-task` | 138-task plan v2.0 | 2026-02-08 |
| `recipe-features` | Feature specifications | Initial |
| `admin-features` | Admin workflow details | Initial |
| `storage-data-model` | Pre-database structure | Initial |
| `auth-context` | Authentication logic | Initial |
| `routing-layouts` | Route configuration | Initial |
| `ui-components-and-styling` | Component library | Initial |
| `notion-implementation-tracking` | Notion sync | Initial |
| `notion-sql-docs` | Notion SQL data | Initial |
| `recent-work-summary-2026-02-13` | Previous session | 2026-02-13 |
| `setup-guide-update-2026-02-13` | Latest changes | 2026-02-13 |

### Memory Naming Patterns Used

1. **Status memories:** `csx3006-database-project-updates` (primary)
2. **Fix memories:** `{name}-fixes-{date}.md` (e.g., `sql-fixes-2026-02-13`)
3. **Work summaries:** `recent-work-summary-{YYYY-MM-DD}.md`
4. **Feature memories:** Lowercase kebab-case (e.g., `recipe-features`, `admin-features`)

---

## Next Serena Improvements (When Needed)

1. **After Phase 4 backend completion:**
   - Create memory documenting backend architecture decisions
   - Add examples of symbol navigation on PHP files
   - Update `csx3006-database-project-updates` with status: Phase 5 pending

2. **After Phase 5 frontend integration:**
   - Create memory documenting localStorage → API migration
   - Update `auth-context` with session-based auth flow
   - Update `storage-data-model` as deprecated/archived

3. **When Notion integration is active:**
   - Update `notion-implementation-tracking` with sync frequency
   - Update `notion-sql-docs` with generated pages

---

## Tools Usage Frequency (This Project)

| Tool | Usage Level | Current Activity |
|-------|--------------|-----------------|
| `check_onboarding_performed` | Every session start | ✅ High |
| `read_memory` | Every session + during work | ✅ High |
| `write_memory` | After significant work | ✅ High |
| `edit_memory` | Incremental updates | ✅ Medium |
| `list_memories` | Session start + checks | ✅ High |
| `file_search` | Finding SQL/scripts | ✅ Medium |
| `grep_search` | Searching content | ✅ Medium |
| `replace_string_in_file` | Code updates | ✅ High |
| `read_file` | Reviewing files | ✅ High |
| `multi_replace_string_in_file` | Bulk updates | ✅ Medium |

---

## Backup Procedure

Run the memory backup script regularly:

```powershell
cd "c:\Assumption University\CSX3006\Class Materials\project\recipe_sharing_system\recipe-sharing-system"
.github\skills\serena-usage\scripts\serena-memory-backup.ps1
```

**When to back up:**
- After completing a phase (currently: after Phase 4, 5, or 6)
- Before major refactoring
- Weekly during active development
- Before any memory cleanup/deletion

This ensures all project intelligence is preserved and can be restored if needed.
