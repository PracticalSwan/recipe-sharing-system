## 2025-05-14 - [Icon-only Button Accessibility]
**Learning:** Icon-only buttons (like those for liking, saving, or deleting) are common in this app but frequently lack `aria-label` or proper keyboard focus visibility. This makes them inaccessible to screen reader users and difficult for keyboard-only users to discover.
**Action:** Always ensure icon-only buttons have an `aria-label` that describes their action, and ensure they are visible when they receive focus, even if they are normally hidden on hover. (Recently updated: Added focus-visible rings to avatar selection and ingredient checklists).

## 2025-05-15 - [Interactive List and Selection Accessibility]
**Learning:** Interactive elements that are not standard HTML form controls (like clickable list items for checklists or custom selection buttons) often lack necessary ARIA roles and keyboard support. This prevents users who rely on assistive technologies or keyboard navigation from interacting with these features.
**Action:** Implement `role="checkbox"`, `tabIndex="0"`, and `aria-checked` for custom checklist items. Add `onKeyDown` handlers to support 'Enter' and 'Space' keys. For custom selection buttons, use `aria-pressed` to indicate state and ensure clear `focus-visible` styles are applied.
