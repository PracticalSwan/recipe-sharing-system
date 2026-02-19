# Recipe Edit Re-approval Workflow Design

**Date:** 2026-02-20
**Author:** Claude
**Status:** Approved

## Problem Statement

Currently, when a contributor edits an already published recipe, the recipe remains published without requiring admin reapproval. This allows potentially inappropriate or incorrect content changes to go live without oversight.

## Requirements

1. When any recipe is edited by its author (contributor), the status must change to `pending`
2. Admins should not be able to edit recipe content directly
3. Admins can only approve/reject/delete/view recipes via dedicated endpoints
4. The re-approval requirement applies to all recipes regardless of current status (published, pending, rejected)

## Proposed Solution

### Backend Changes

**File:** [backend/api/recipes.php](backend/api/recipes.php)
**Function:** `handleUpdateRecipe` (line ~298)

#### Current Behavior

The current logic (lines 315-319) preserves the recipe's existing status unless an admin explicitly provides a new status:

```php
// Preserve status unless admin explicitly changes it
$nextStatus = $recipe['status'];
if (isset($data['status']) && in_array($data['status'], ['published', 'pending', 'rejected'], true) && $user['role'] === 'admin') {
    $nextStatus = $data['status'];
}
```

#### New Behavior

Replace the status preservation logic with:

1. **Block admin content edits:** Reject admin attempts to edit recipe content with 403 error
2. **Auto-set pending status:** All contributor edits set status to `pending`
3. **Remove status override capability:** Contributors cannot set status during edit

```php
// Contributors can edit, but status always becomes pending for re-approval
// Admins cannot edit recipe content - use /status endpoint instead
if ($user['role'] === 'admin') {
    errorResponse('Admins cannot edit recipe content. Use the status endpoint to approve/reject.', 403);
}

// Always require re-approval when recipe is edited
$nextStatus = 'pending';
```

### Authorization Logic Update

The current authorization check (line 311):
```php
if ((int) $recipe['author_id'] !== (int) $user['id'] && $user['role'] !== 'admin') {
    errorResponse('Not authorized', 403);
}
```

This will be updated to remove admin edit capability:
```php
// Only the recipe author can edit
if ((int) $recipe['author_id'] !== (int) $user['id']) {
    errorResponse('Not authorized', 403);
}

// Explicitly block admins from editing content
if ($user['role'] === 'admin') {
    errorResponse('Admins cannot edit recipe content. Use the status endpoint to approve/reject.', 403);
}
```

## Data Flow

```
┌─────────────────┐
│ Contributor     │
│ edits recipe    │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────┐
│ PUT /api/recipes/{id}           │
│ - JSON body with recipe data    │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│ Backend Validation              │
│ - User is authenticated         │
│ - User is recipe author         │
│ - User is NOT admin             │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│ Update Recipe                   │
│ - Update all recipe fields      │
│ - Set status = 'pending'        │
│ - Update ingredients/instructions│
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│ Return updated recipe           │
│ status: 'pending'               │
└─────────────────────────────────┘
         │
         ▼
┌─────────────────┐
│ Admin reviews   │
│ via dashboard   │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────┐
│ PUT /api/recipes/{id}/status    │
│ { status: 'published' }         │
└─────────────────────────────────┘
```

## Error Handling

| Scenario | HTTP Status | Response Message |
|----------|-------------|------------------|
| Admin attempts recipe edit | 403 | "Admins cannot edit recipe content. Use the status endpoint to approve/reject." |
| Non-owner attempts edit | 403 | "Not authorized" |
| Recipe not found | 404 | "Recipe not found" |
| Invalid JSON body | 400 | "Invalid JSON body" |
| Missing title | 400 | "Title is required" |

## Testing Scenarios

### Success Cases

1. **Contributor edits published recipe**
   - Input: Recipe with `status: 'published'`
   - Action: Contributor updates title/description
   - Expected: Status changes to `pending`

2. **Contributor edits pending recipe**
   - Input: Recipe with `status: 'pending'`
   - Action: Contributor adds ingredient
   - Expected: Status remains `pending`

3. **Contributor edits rejected recipe**
   - Input: Recipe with `status: 'rejected'`
   - Action: Contributor modifies instructions
   - Expected: Status changes to `pending`

### Failure Cases

4. **Admin attempts to edit recipe content**
   - Input: Admin user, recipe data
   - Action: PUT to `/api/recipes/{id}`
   - Expected: 403 error, recipe unchanged

5. **Non-owner attempts edit**
   - Input: Different contributor user
   - Action: PUT to `/api/recipes/{id}`
   - Expected: 403 error, recipe unchanged

### Admin Workflow (Unchanged)

6. **Admin approves recipe**
   - Input: Admin user, `{ status: 'published' }`
   - Action: PUT to `/api/recipes/{id}/status`
   - Expected: Recipe status becomes `published`

7. **Admin rejects recipe**
   - Input: Admin user, `{ status: 'rejected' }`
   - Action: PUT to `/api/recipes/{id}/status`
   - Expected: Recipe status becomes `rejected`

## API Contract Changes

### PUT /api/recipes/{id}

**Before:**
- Recipe author OR admin could edit
- Status preserved unless admin explicitly changed it

**After:**
- Only recipe author can edit (admins blocked)
- Status always set to `pending`
- Admin must use `/status` endpoint for status changes

### PUT /api/recipes/{id}/status

**No changes** - This endpoint remains admin-only and is the correct way for admins to approve/reject recipes.

## Implementation Checklist

- [ ] Update `handleUpdateRecipe` authorization logic
- [ ] Replace status preservation with forced `pending` status
- [ ] Add admin edit blocking with appropriate error message
- [ ] Test all scenarios in testing checklist
- [ ] Update API documentation if needed
- [ ] Update CHANGELOG.md

## Impact Assessment

**Breaking Changes:** Yes, for admins who previously edited recipe content directly

**Migration:** None required - backend logic change only

**User Impact:**
- Contributors: Recipes will require reapproval after edits (intended behavior)
- Admins: Must use status endpoint instead of editing content directly

**Database Impact:** None - no schema changes required

## Alternatives Considered

1. **Conditional reset:** Only published recipes → pending. Rejected as inconsistent.
2. **Role-based tracking:** Allow admins to edit content without triggering pending. Rejected per requirements.

## Approval

- [x] Requirements clarified with user
- [x] Design approved
- [ ] Implementation plan created
- [ ] Code changes implemented
- [ ] Testing completed
