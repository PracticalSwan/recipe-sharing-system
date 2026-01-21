## 2025-05-14 - [Icon-only Button Accessibility]
**Learning:** Icon-only buttons (like those for liking, saving, or deleting) are common in this app but frequently lack `aria-label` or proper keyboard focus visibility. This makes them inaccessible to screen reader users and difficult for keyboard-only users to discover.
**Action:** Always ensure icon-only buttons have an `aria-label` that describes their action, and ensure they are visible when they receive focus, even if they are normally hidden on hover.
