## 2025-05-15 - [Information Leakage via Error Responses]
**Vulnerability:** API endpoints were returning detailed exception messages (including database errors) to the client during 500 Internal Server Errors.
**Learning:** Centralizing error handling in a helper function allowed for a high-leverage fix that masked these details globally.
**Prevention:** Always genericize server-side error messages before sending them to the client and log the details internally.
