# SQL Import Cleanup and Comment Removal (2026-02-14)

## User Request
1) Fix current phpMyAdmin import error in `02_create_tables.sql`.
2) Search/fix other SQL scripts to avoid additional import errors.
3) Remove unnecessary information/comments in database scripts.

## Changes Applied
- Rebuilt `database/02_create_tables.sql` into a clean, valid SQL-only DDL script.
  - Removed malformed duplicate `) ENGINE=...` fragments and trailing-comma breakpoints.
  - Preserved 13-table schema and FK behavior.
  - Escaped `user` identifier with backticks in DDL/FK references.
- Removed non-essential comment lines from all `database/*.sql` scripts.
- Normalized `user` table identifier usage across all database scripts to avoid parser conflicts:
  - `FROM user` -> `FROM `user``
  - `JOIN user` -> `JOIN `user``
  - `ON user` -> `ON `user``
  - `INSERT INTO user` -> `INSERT INTO `user``
  - `UPDATE user` -> `UPDATE `user``
  - `DELETE FROM user` -> `DELETE FROM `user``
  - `DROP TABLE IF EXISTS user` -> `DROP TABLE IF EXISTS `user``
  - `REFERENCES user(...)` -> `REFERENCES `user`(...)`

## Validation Performed
- Verified no remaining SQL comment markers in `database/*.sql` (`--`, `/*`, `*/`).
- Verified no unescaped identifier patterns for the `user` table after SQL keywords.
- Verified no `trailing comma before )` patterns across all database scripts.
- Confirmed `DELIMITER` pairs still exist in procedure/trigger scripts.

## Documentation
- Updated `README.md` with a note that SQL scripts in `database/` are import-ready with SQL-only formatting.
- `CHANGELOG.md` does not exist in this project, so no changelog update was possible.

## Notes
- Validation here is static (pattern/syntax-shape checks) and does not execute SQL against a live MySQL/MariaDB server in this environment.
- If phpMyAdmin still errors, rerun starting from `01_create_database.sql` through `14_backup_restore.sql` in order and capture exact failing script + line.