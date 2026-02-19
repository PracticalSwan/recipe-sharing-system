# Recipe Edit Re-approval Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Modify the recipe update workflow so that any recipe edit by contributors automatically changes status to 'pending' for admin reapproval, and block admins from editing recipe content directly.

**Architecture:** Update the `handleUpdateRecipe` function in the PHP backend to: (1) reject admin edit attempts with 403, (2) force status to 'pending' for all contributor edits, and (3) remove the admin status override capability. No database or frontend changes required.

**Tech Stack:** PHP 8.x, PDO, MySQL/MariaDB, REST API

---

## Task 1: Update Authorization Logic to Block Admin Edits

**Files:**
- Modify: `backend/api/recipes.php:311-313`

**Step 1: Read the current authorization logic**

Read lines 305-320 of `backend/api/recipes.php` to understand the current authorization check that allows both recipe owners and admins to edit recipes.

**Step 2: Modify authorization to block admins**

Replace the authorization check to only allow the recipe author to edit:

```php
// Only the recipe author can edit (admins cannot edit content)
if ((int) $recipe['author_id'] !== (int) $user['id']) {
    errorResponse('Not authorized', 403);
}

// Explicitly block admins from editing recipe content
if ($user['role'] === 'admin') {
    errorResponse('Admins cannot edit recipe content. Use the status endpoint to approve/reject.', 403);
}
```

**Step 3: Commit**

```bash
git add backend/api/recipes.php
git commit -m "feat(block): prevent admins from editing recipe content

Admins can only approve/reject recipes via the dedicated status endpoint,
not edit recipe content directly. Contributors retain edit capability.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 2: Replace Status Preservation with Forced Pending Status

**Files:**
- Modify: `backend/api/recipes.php:315-319`

**Step 1: Remove old status preservation logic**

Delete lines 315-319 which contain the logic that preserves the existing status unless an admin explicitly changes it:

```php
// DELETE these lines:
// Preserve status unless admin explicitly changes it
$nextStatus = $recipe['status'];
if (isset($data['status']) && in_array($data['status'], ['published', 'pending', 'rejected'], true) && $user['role'] === 'admin') {
    $nextStatus = $data['status'];
}
```

**Step 2: Add forced pending status logic**

Replace with simple forced pending status:

```php
// Always require re-approval when recipe is edited
$nextStatus = 'pending';
```

**Step 3: Commit**

```bash
git add backend/api/recipes.php
git commit -m "feat(workflow): auto-set recipe status to pending on edit

Any recipe edit by contributors now requires admin reapproval.
Status is automatically changed to pending regardless of previous state.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 3: Verify the Complete handleUpdateRecipe Function

**Files:**
- Review: `backend/api/recipes.php:297-412`

**Step 1: Review the updated function**

Read the entire `handleUpdateRecipe` function to verify the changes are correct. The function should now:
1. Check authentication (line 299)
2. Validate JSON input (lines 300-303)
3. Fetch recipe and verify authorship (lines 305-313) - NOW BLOCKS ADMINS
4. Set status to pending (lines 315-316) - NOW FORCES PENDING
5. Process categories (lines 318-323)
6. Update recipe in database (lines 325-348)

**Step 2: Verify no admin status override remains**

Search the file for any remaining references to admin status override in the update function:

```bash
grep -n "admin.*status" backend/api/recipes.php
```

Expected: Only the admin activity logging in `handleRecipeStatus` function should appear, not in `handleUpdateRecipe`.

**Step 3: No commit needed**

This is a verification step only.

---

## Task 4: Manual Testing - Contributor Edit

**Prerequisites:** XAMPP server running, database seeded with test data

**Step 1: Log in as a contributor**

Use credentials: `user@cookhub.com` / `user` (or any active contributor account)

**Step 2: Find a published recipe to edit**

Navigate to recipe list, note a recipe ID that is currently `published`. You can check via browser DevTools Network tab when loading recipes.

**Step 3: Edit the recipe via API**

Open browser DevTools Console and execute:

```javascript
fetch('http://localhost/recipe-sharing-system-deploy/backend/api/recipes/1', {
  method: 'PUT',
  credentials: 'include',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    title: 'Updated Recipe Title',
    description: 'This recipe was edited',
    categories: ['Dinner'],
    difficulty: 'Medium',
    prepTime: 30,
    cookTime: 45,
    servings: 4,
    ingredients: [
      { name: 'Test Ingredient', quantity: '1', unit: 'cup' }
    ],
    instructions: [
      'Step 1: Do this',
      'Step 2: Do that'
    ],
    images: []
  })
})
.then(r => r.json())
.then(data => console.log('Recipe status after edit:', data.status))
```

Expected: `data.status` should be `'pending'`

**Step 4: Verify via admin dashboard**

Log in as admin (`admin@cookhub.com` / `admin`), check Admin Recipes page. The edited recipe should appear in Pending section.

---

## Task 5: Manual Testing - Admin Edit Blocked

**Prerequisites:** XAMPP server running

**Step 1: Log in as admin**

Use credentials: `admin@cookhub.com` / `admin`

**Step 2: Attempt to edit a recipe**

Open browser DevTools Console and execute:

```javascript
fetch('http://localhost/recipe-sharing-system-deploy/backend/api/recipes/1', {
  method: 'PUT',
  credentials: 'include',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    title: 'Admin Trying to Edit',
    description: 'This should fail',
    categories: ['Lunch'],
    difficulty: 'Easy',
    prepTime: 20,
    cookTime: 30,
    servings: 2,
    ingredients: [{ name: 'Ingredient', quantity: '1', unit: 'piece' }],
    instructions: ['Do something'],
    images: []
  })
})
.then(r => r.json())
.then(data => console.log('Response:', data))
.catch(err => console.error('Error:', err))
```

Expected: Error response with 403 status and message about admins not being able to edit content

**Step 3: Verify admin can still approve via status endpoint**

```javascript
fetch('http://localhost/recipe-sharing-system-deploy/backend/api/recipes/1/status', {
  method: 'PUT',
  credentials: 'include',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ status: 'published' })
})
.then(r => r.json())
.then(data => console.log('Approval response:', data))
```

Expected: Success message indicating recipe status updated

---

## Task 6: Update CHANGELOG

**Files:**
- Modify: `CHANGELOG.md`

**Step 1: Add entry to CHANGELOG**

Add a new entry under the appropriate unreleased version section:

```markdown
## [Unreleased]

### Changed
- Recipe edits by contributors now automatically change status to 'pending' requiring admin reapproval
- Admins can no longer edit recipe content directly (must use approve/reject workflow)
```

**Step 2: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: update CHANGELOG for recipe re-approval workflow

Document that recipe edits now require reapproval and admins cannot
edit recipe content directly.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

## Task 7: Create Git Tag for Release

**Step 1: Review all commits**

```bash
git log --oneline -5
```

Expected: Should see the implementation commits from this plan.

**Step 2: Create version tag**

Assuming this is version 1.0.5 (check existing tags with `git tag`):

```bash
git tag -a v1.0.5 -m "Release v1.0.5: Recipe edit re-approval workflow"
```

**Step 3: Push changes and tags**

```bash
git push origin main
git push origin v1.0.5
```

---

## Testing Checklist

Before considering this feature complete, verify:

- [ ] Contributor editing published recipe → status becomes 'pending'
- [ ] Contributor editing pending recipe → status remains 'pending'
- [ ] Contributor editing rejected recipe → status becomes 'pending'
- [ ] Admin attempting to edit recipe → receives 403 error
- [ ] Admin approving via `/status` endpoint → works correctly
- [ ] Admin rejecting via `/status` endpoint → works correctly
- [ ] Non-owner attempting edit → receives 403 error
- [ ] Recipe ingredients/instructions/images update correctly during edit
- [ ] CHANGELOG updated with breaking change note

---

## Files Modified Summary

| File | Lines Changed | Description |
|------|---------------|-------------|
| `backend/api/recipes.php` | 311-319 | Updated authorization and status logic |
| `CHANGELOG.md` | New section | Documentation of changes |

## Related Documentation

- Design document: `docs/plans/2026-02-20-recipe-edit-reapproval-design.md`
- API documentation: `docs/API_DOCUMENTATION.md` (may need update)
- Database schema: `docs/DATABASE_SCHEMA.md` (no changes needed)

---

**Implementation complete when:** All tasks finished, testing checklist verified, and commits pushed to main branch.
