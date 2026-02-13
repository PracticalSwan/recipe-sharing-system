---
name: serena-usage
description: Serena MCP Server usage for project memory management, code navigation, and intelligent refactoring. Use when working with Serena memories, managing project context across sessions, performing symbol-based code navigation, executing safe code refactoring, or maintaining continuity between AI agent sessions using Serena's memory system. Triggered by keywords like Serena MCP, project memory, code navigation, symbol navigation, intelligent refactoring, memory management, AI session continuity, Serena memory system.
license: Complete terms in LICENSE.txt
---

# Serena Usage

Effective usage of the Serena MCP Server for project memory management, code intelligence, and maintaining continuity across AI agent sessions.

## Skill Paths

- Workspace skills: `.github/skills/`
- Global skills: `C:/Users/LOQ/.copilot/skills/`

## Activation Conditions

- Managing project memories for AI session continuity
- Navigating codebases using symbol-based tools
- Performing code refactoring with Serena's symbol management
- Setting up Serena onboarding for new projects
- Using Serena's memory system for project context preservation

## Non-Activation Conditions

**Do NOT activate this skill when:**
- User requests general programming help without Serena context
- Task is in a workspace not Serena-enabled
- User asks basic questions about VS Code or AI tools without Serena
- Request is for regular development tasks without Serena tool usage
- User wants simple file operations without Serena workspace context
- Task involves Serena documentation but not using Serena tools in workflow

## Prerequisites

- Serena MCP Server configured and running
- Onboarding completed for the target project (use `check_onboarding_performed` first)
- If not onboarded, run `onboarding` tool before any operations

---

## Onboarding Workflow

### First-Time Project Setup
1. Call `check_onboarding_performed` to verify status
2. If not performed, call `initial_instructions` to read the Serena Instructions Manual
3. Call `onboarding` to initialize the project
4. Serena analyzes the project structure and creates initial context

### What Onboarding Captures
- Project language and framework detection
- Directory structure analysis
- Key file identification
- Symbol index creation
- Initial memory scaffolding

---

## Memory Management

### Core Concepts
Serena memories persist between sessions, providing continuity for AI agents across work sessions.

### Memory Operations

| Operation | Tool | Purpose |
|-----------|------|---------|
| List all | `list_memories` | See available memories |
| Read one | `read_memory` | Access specific memory content |
| Create | `write_memory` | Store new information |
| Update | `edit_memory` | Modify existing memory |
| Remove | `delete_memory` | Clean up obsolete information |

### Memory Structure

Serena memories use the Memory Bank naming convention for consistency and clarity. This structure organizes project intelligence into core files and tasks.

#### Core Files

| Memory Name | Purpose |
|-------------|---------|
| `project-brief` | Foundation document defining core requirements and goals. Shapes all other memories. Created at project start. |
| `product-context` | Why this project exists, problems it solves, how it should work, and user experience goals |
| `active-context` | Current work focus, recent changes, and next steps with active decisions and considerations |
| `system-patterns` | System architecture, key technical decisions, design patterns in use, and component relationships |
| `tech-context` | Technologies used, development setup, technical constraints, and dependencies |
| `progress` | What works, what's left to build, current status, and known issues |

#### Task Management Memories

Tasks are managed with dedicated memory files for tracking progress and history.

| Memory Name | Purpose |
|-------------|---------|
| `task-{id}` | Individual task tracking (e.g., TASK001-implement-login.md) with original request, thought process, implementation plan, and progress logs |
| `task-index` | Master list of all tasks with IDs, names, statuses (Pending/In Progress/Completed/Abandoned), and last updated dates |

#### Task Memory Structure

Each task memory follows this format:

```markdown
# [Task ID] - [Task Name]

**Status:** [Pending/In Progress/Completed/Abandoned]
**Added:** [Date Added]
**Updated:** [Date Last Updated]

## Original Request
[The original task description as provided by the user]

## Thought Process
[Documentation of the discussion and reasoning that shaped the approach]

## Implementation Plan
- [Step 1]
- [Step 2]
- [Step 3]

## Progress Tracking

**Overall Status:** [Not Started/In Progress/Blocked/Completed] - [Completion Percentage]

### Subtasks
| ID | Description | Status | Updated | Notes |
|----|-------------|--------|---------|-------|
| 1.1 | [Subtask description] | [Complete/In Progress/Not Started/Blocked] | [Date] | [Relevant notes] |

## Progress Log
### [Date]
- Updated subtask 1.1 status to Complete
- Started work on subtask 1.2
- Encountered issue with [specific problem]
- Made decision to [approach/solution]
```

#### Task Index Structure

The task-index memory maintains a structured record:

```markdown
# Tasks Index

## In Progress
- [TASK003] Implement user authentication -Working on OAuth integration
- [TASK005] Create dashboard UI -Building main components

## Pending
- [TASK006] Add export functionality -Planned for next sprint

## Completed
- [TASK001] Project setup -Completed on 2025-03-15
- [TASK002] Create database schema -Completed on 2025-03-17
```

#### Commands

When you request **add task** or **create task**, the agent will:
1. Create a new task memory with a unique Task ID
2. Document the thought process about the approach
3. Develop an implementation plan
4. Set an initial status
5. Update the task-index memory

To view tasks, the command **show tasks [filter]** will display filtered lists with valid filters:
- **all** - Show all tasks regardless of status
- **active** - Show only "In Progress" tasks
- **pending** - Show only "Pending" tasks
- **completed** - Show only "Completed" tasks
- **blocked** - Show only "Blocked" tasks
- **recent** - Show tasks updated in the last week

### When to Update Memories

**Update core memories when:**
- After completing significant features or functionality
- When making architectural decisions
- Discovering new project patterns or conventions
- Changing technical stack or dependencies
- Modifying data models or schemas
- At the start and end of each work session

**Update task memories when:**
- Creating new tasks via "create task" command
- Making progress on existing tasks
- Completing subtasks or entire tasks
- Encountering blockers or issues
- Changing task status (Pending → In Progress → Completed/Abandoned)

### Memory Bank Documentation Guidelines

The Serena memories follow the Memory Bank structure for comprehensive project intelligence. Key guidelines:

**Task Progress Updates:**
- Always update both the subtask status table AND the progress log when making progress
- The subtask table provides quick visual reference of current status
- The progress log captures the narrative and details of the work process
- Each progress log entry should include date, accomplishments, challenges, and decisions
- Update task status in `task-index` to reflect current progress

**Documentation Flow:**
```
New Task → Create task-{id}.py memory → Update task-index
Progress → Update task-{id}.py log table → Update task-index
Discovery → Create/ update appropriate core memory
Architecture Decision → Update system-patterns memory
Completion → Update progress memory → Clear from active tasks
```

**Active-Context Format:**
```markdown
## Active Context — Updated [Date]

### Current Focus
- Implementing user authentication with NextAuth.js
- Building recipe CRUD API routes

### Recent Decisions
- Chose MongoDB Atlas over Cosmos DB for cost
- Using server components for recipe listing page

### Blockers
- Image upload size limit needs investigation

### Next Steps
1. Complete login/signup UI
2. Add recipe creation form
3. Set up image upload to Blob Storage
```

### Memory Writing Guidelines
```markdown
## Active Context — Updated [Date]

### Current Focus
- Implementing user authentication with NextAuth.js
- Building recipe CRUD API routes

### Recent Decisions
- Chose MongoDB Atlas over Cosmos DB for cost
- Using server components for recipe listing page

### Blockers
- Image upload size limit needs investigation

### Next Steps
1. Complete login/signup UI
2. Add recipe creation form
3. Set up image upload to Blob Storage
```

---

## Code Navigation

### Symbol-Based Navigation

| Tool | Use Case |
|------|----------|
| `find_symbol` | Locate specific classes, functions, variables by name path |
| `find_referencing_symbols` | Find all usages of a symbol across the codebase |
| `get_symbols_overview` | High-level summary of symbols in a file |

### Navigation Workflow
1. Use `get_symbols_overview` on a file to understand its structure
2. Use `find_symbol` to locate a specific definition
3. Use `find_referencing_symbols` to understand impact before changes

---

## Code Refactoring

### Safe Refactoring with Serena

| Tool | Operation |
|------|-----------|
| `rename_symbol` | Rename across all references |
| `replace_symbol_body` | Replace implementation of a function/method |
| `insert_after_symbol` | Add new code after a definition |
| `insert_before_symbol` | Add new code before a definition |

### Refactoring Workflow
1. **Understand**: Use `find_symbol` and `get_symbols_overview`
2. **Assess Impact**: Use `find_referencing_symbols` to see all usages
3. **Plan**: Think through the changes needed
4. **Execute**: Use rename/replace/insert tools
5. **Verify**: Re-check references to confirm correctness
6. **Document**: Update memories with the change rationale

---

## File Search

| Tool | Purpose |
|------|---------|
| `find_file` | Locate files matching a name pattern |
| `list_dir` | Browse directory contents |
| `search_for_pattern` | Search for text/regex patterns across codebase |

---

## Task Adherence

Serena provides reflection tools to maintain focus:

| Tool | When to Use |
|------|------------|
| `think_about_collected_information` | After gathering context — is it sufficient? |
| `think_about_task_adherence` | After many interactions — am I still on track? |
| `think_about_whether_you_are_done` | Before concluding — have I completed everything? |

---

## Session Workflow

### Starting a Session
1. `list_memories` → review all 10 available project memories
2. `read_memory` → load relevant memories for current work phase:
   - **Always:** Read `project-overview` (current status, tech stack, next steps)
   - **Phase 4 (Backend):** Read `database-integration-implementation-plan-task` (TASK-057 to TASK-092)
   - **Feature work:** Read specific feature memory (admin-features, recipe-features, auth-context)
   - **SQL work:** Read `csx3006-sql-fixes-2026-02-13.md` (column conventions, FK patterns)
   - **Notion sync:** Read `notion-implementation-tracking.md` (update protocol)
3. Begin work with current phase context

### During a Session
- **SQL/database work:** Create `{topic}-fixes-{date}.md` memory for bug fixes (e.g., column name corrections)
- **Feature implementation:** Update or create `{feature-name}.md` memory for feature specs
- **Phase completion:** Update `project-overview.md` with new status percentage
- **Notion updates:** Use `notion-update-page` after completing plan tasks (TASK-001 → TASK-138)
- **Code navigation:** Use symbol tools to explore React components and future PHP backend files

---

## Best Practices

- Always check onboarding before first use on a project
- Keep memories concise — prefer structured data over prose
- Update memories incrementally, not in bulk rewrites
- Use consistent naming for memories across projects (Memory Bank convention)
- Leverage `think_about_*` tools for self-reflection on complex tasks
- For task tracking: Always update both subtask table AND progress log in task memories
- Keep `task-index` synchronized with task memory status changes
- Delete obsolete memories to prevent confusion
- Use task IDs from `task-index` as reference when discussing work

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Onboarding not detected | Run `onboarding` tool explicitly |
| Memory not found | Check exact name with `list_memories` |
| Symbol not found | Ensure file is indexed; try broader name |
| Stale memories | Use `edit_memory` to update with current state |
| Conflicting memories | Delete outdated entry, create fresh one |

---

## References & Resources

### Documentation
- [Memory Management](./references/memory-management.md) — Memory naming conventions, lifecycle, and maintenance best practices
- [Symbol Navigation](./references/symbol-navigation.md) — find_symbol and find_referencing_symbols patterns and workflows

### Project-Specific Guide (Recipe Sharing System)

**Current Memory Structure (10 active memories):**

| Memory | Purpose | Notes |
|---------|---------|--------|
| `project-overview` | Project status, tech stack, next steps | Central reference, read first |
| `database-integration-implementation-plan-task` | 138-task plan v2.0 status | 38% complete (Phases 1-3 done) |
| `csx3006-sql-fixes-2026-02-13` | SQL script corrections | Keep for debugging |
| `notion-implementation-tracking` | Notion sync protocol | Update when completing tasks |
| `admin-features` | Admin workflow, moderation, user management | Feature specs only |
| `recipe-features` | Recipe CRUD, search, reviews, engagement | Feature specs only |
| `auth-context` | Session-based authentication flow | Phase 4 backend, Phase 5 integration |
| `routing-layouts` | Route configuration and page layouts | HashRouter with layout guards |
| `storage-data-model` | Pre-Phase 5 localStorage structure | Will be replaced by API |
| `ui-components-and-styling` | Component library and Tailwind v4 | Reusable components |

**Session-Start Pattern (Phase 4 — Backend Pending):**
1. `list_memories` → verify 10 memories available
2. Read `project-overview` → current status (38% complete, Phases 1-3 done)
3. Read `database-integration-implementation-plan-task` → Phase 4 tasks (TASK-057 to TASK-092)
4. Begin PHP backend development: `backend/config/database.php`, `backend/helpers/`, then `backend/api/`

**Project-Specific Best Practices:**

**Database Conventions:**
- Database: `cookhub` (utf8mb4_unicode_ci)
- Tables: singular (user, recipe, ingredient, etc.)
- Columns: snake_case, `id` PKs
- PK access: `WHERE id = ?` on parent tables, FK references on child tables
- FKs: `{table}_id` columns

**Architecture:**
- Plain PHP (no frameworks, no Composer)
- Structure: `backend/{config, helpers, api}/`
- Each API file handles routing via `$_SERVER['REQUEST_METHOD']`
- Auth: Session-based (HttpOnly cookies, `session` table)
- HTTP: Native `fetch()` with `credentials: 'include'`

**Documentation Flow:**
- SQL fixes → create `{topic}-fixes-{date}.md` memory
- Major milestones → update `project-overview.md`
- Phase completion → update `database-integration-implementation-plan-task.md`
- Notion sync → update `notion-implementation-tracking.md`

**Naming Patterns Used:**
- Feature memories: lowercase kebab-case (admin-features, recipe-features, auth-context)
- Fix memories: `{name}-fixes-{date}.md`
- Status memories: `{project}-updates.md` or `{plan}-task.md`

---

## Memory Reference Table (CSX3006 Project)

| Category | Memory Name | Update Frequency | When to Read |
|----------|---------------|------------------|--------------|
| **Status & Plan** | `project-overview` | After phase completion, architecture decisions | Always first when starting session |
| **Task Tracking** | `database-integration-implementation-plan-task` | After phase completion | When starting backend/frontend work |
| **SQL Fixes** | `csx3006-sql-fixes-2026-02-13.md` | When fixing database issues | During SQL/database work |
| **Notion Sync** | `notion-implementation-tracking` | When Notion sync pattern changes | Before updating Notion pages |
| **Feature Specs** | `admin-features`, `recipe-features`, `auth-context` | Feature changes/improvements | Implementing related features |
| **Reference** | `routing-layouts`, `storage-data-model`, `ui-components-and-styling` | Rarely changes | Quick lookup for these topics |

### Scripts
- [Memory Backup](./scripts/serena-memory-backup.ps1) — PowerShell script to backup Serena memory files with timestamps

### Examples
- [Refactoring Workflow](./examples/refactoring-workflow.md) — 13-step refactoring walkthrough using Serena tools

---

## Memory Management Strategy for This Project

**Why 10 memories (not 15 from Memory Bank standard):**
- Project tracks implementation plan via `plan/upgrade-database-integration-1.md` (138 tasks) instead of task memories
- No individual `task-{id}` memories needed (tasks are in plan file)
- No `task-index` or `progress` memories (status in `project-overview.md`)
- Feature specs kept concise (admin-features, recipe-features, auth-context at ~500 bytes each)
- One-line reference memories for quick lookups (routing-layouts, storage-data-model, ui-components-and-styling)

**When to create new memories:**
- SQL/script fixes: `{topic}-fixes-{date}.md` (e.g., csx3006-sql-fixes-2026-02-13.md)
- Feature documentation: `{feature-name}.md` (e.g., admin-features.md)
- Major milestones: Update `project-overview.md` (status changes, architecture decisions)

**When NOT to create memories:**
- Individual tasks (use `upgrade-database-integration-1.md` task list)
- Everyday progress (project status tracked in `project-overview.md`)
- Code samples (code is in actual files, not memories)
- Historical one-time events (delete when obsolete)
```
