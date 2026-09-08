---
name: vibe-code-security-audit
description: Security checklist for reviewing applications built via vibe-coding (Claude, Codex, Cursor, v0, Bolt, Lovable, etc.) before launch or deployment. Trigger this whenever the user says things like "check my app", "what should I review before launching", "is this code secure", "security review", "don't want to get hacked", "give me a pre-deploy checklist", or references anything about auditing a vibe-coded project — even if they don't say "security audit" explicitly. Also use this for checking leaked API keys, database security (e.g. Supabase/Firebase), Row Level Security, authentication, rate limiting, and production hardening.
---

# Vibe-Coding Security Audit Checklist

This skill is a 20-item, actionable checklist for auditing the security of applications built mostly by AI coding tools (Claude Code, Codex, Cursor, v0, Bolt, Lovable, etc.). These codebases usually work functionally but often have basic security holes, because the AI defaults to optimizing for "it works," not "it's secure."

## How to use this

When the user has code or a project they want reviewed before shipping:

1. **Identify the project**: tech stack (frontend, backend, database), and whether any API/database/service keys live in the code or env files.
2. **Go through each item in the checklist below one by one** — using `grep`/code search, reading config files, and inspecting the git repo.
3. For each item, report: **current status** (found/not found, risk level), and a **specific fix** with code or commands.
4. End with a **risk summary**: which items are Critical, which are Medium, and the priority order for fixing them.

If the user just asks "explain what each item means" without providing any code, walk through this checklist with explanation and examples, without assuming a specific stack.

---

## The 20-Item Checklist

### 1. Hide API keys
Keys should never be hardcoded in frontend code or committed files. They belong in server-side `.env` files or a secret manager. Check with: `grep -rn "sk-\|api_key\|apikey\|API_KEY" --include=*.{js,ts,py,json}` across the whole project, and confirm sensitive keys are only read server-side, never bundled into client code.

### 2. Purge secrets from git history
If a key was ever committed, it remains in git history even after being deleted from the file. The critical step is to **rotate/revoke** the key, then scrub it from history with `git filter-repo` or the BFG Repo-Cleaner, and add `.env` to `.gitignore`. If the repo was ever public, assume the key is compromised.

### 3. Only expose the public database key
Services like Supabase/Firebase have an "anon/public" key and a "service_role/admin" key. Only the public key belongs in frontend code; the service/admin key must never appear in client code or a browser bundle, since it grants full database access.

### 4. Enable Row Level Security (RLS)
Without RLS, the public database key alone can grant access to every table. Verify each table has an explicit policy (e.g. `auth.uid() = user_id`) and that RLS is enabled by default, not just on some tables.

### 5. Encrypt sensitive data
Sensitive data (payment info, national IDs, tokens) should be stored encrypted at rest, or at least hashed/masked, never as plaintext. For highly sensitive fields, use column-level encryption or an external KMS.

### 6. Enforce authentication server-side
Never rely solely on client-side auth checks (like `if (user.isAdmin)` in React) — a user can bypass them. Every sensitive endpoint must verify the token/session on the server.

### 7. Lock down record access (IDOR)
Verify that a user can't view or modify another user's record just by changing an id in the URL or body (e.g. `/api/orders/123` to `124`). Every query should check ownership (`user_id = current_user`) in addition to the id.

### 8. Prevent mass assignment on sensitive fields
Make sure a user can't change fields like `role`, `isAdmin`, `price`, or `balance` via the request body. Use an explicit allow-list of editable fields instead of accepting the whole input object.

### 9. Secure session cookies
Session cookies should have `HttpOnly`, `Secure`, and `SameSite=Lax/Strict` flags to resist XSS and CSRF. Session tokens should never be stored in `localStorage`.

### 10. Hash passwords
Passwords must never be stored as plaintext or with weak algorithms (MD5, unsalted SHA1). Use `bcrypt`, `argon2`, or `scrypt` with a proper salt.

### 11. Rate-limit login attempts
Without rate limiting, a login form is vulnerable to brute-force attacks. Add a limit on attempts (e.g. 5 per minute per IP/account) plus temporary lockout.

### 12. Add bot protection
Signup, login, and submission forms (contact/comment) should be protected against bots and spam with CAPTCHA (e.g. hCaptcha/Turnstile) or a honeypot field.

### 13. Parameterize queries (prevent SQL injection)
Never concatenate raw user input directly into a query string. Use prepared/parameterized statements or an ORM; `grep` for patterns like `` `SELECT * FROM ... ${input}` ``.

### 14. Validate all inputs
Every input (body, query, params, headers, file uploads) must be validated server-side: type, length, format. Use a library like zod/joi/pydantic; client-side validation alone is not sufficient.

### 15. Escape user-generated content (XSS)
Any user-supplied content that gets rendered into HTML later must be escaped/sanitized (e.g. with DOMPurify) to prevent script injection. Watch for `dangerouslySetInnerHTML` or `v-html` used without sanitization.

### 16. Restrict file uploads
File uploads should be restricted by type (checking actual MIME type, not just the extension), size, and storage destination. Uploaded files should not be stored in an executable path, and filenames should ideally be randomized/hashed.

### 17. Trim API responses
API responses shouldn't return more than the frontend actually needs (e.g. an entire user record including password hashes or internal tokens). Serialize only the required fields.

### 18. Add security HTTP headers
Add headers like `Content-Security-Policy`, `X-Frame-Options`, `X-Content-Type-Options: nosniff`, and `Strict-Transport-Security` (e.g. via helmet in Express or the equivalent for your framework).

### 19. Force HTTPS
All traffic should be HTTPS-only; HTTP requests should redirect, and cookies should carry the `Secure` flag.

### 20. Scan dependencies
Scan project dependencies with `npm audit`, `pip-audit`, or Snyk/Dependabot to catch vulnerable libraries and keep them updated; add this as a recurring/CI step, not a one-time check.

---

## Output report format

For each project, present findings like this (table or list):

| # | Item | Status | Risk | Required action |
|---|------|--------|------|------------------|
| 1 | API key hidden | ❌ Key found in frontend code | Critical | Move to server-side .env + rotate the key |
| ... | ... | ... | ... | ... |

Finish with a summary of the top 3–5 Critical actions that should be fixed today.

## Important notes

- If the user only shares a small code snippet (not the whole project), only review the checklist items relevant to that snippet, and note that the remaining items require seeing the full project.
- Never print a real key/secret found in the code back in full in your response; just say where it was found and recommend rotating it.
- This checklist is stack-agnostic and general-purpose. For a specific stack (Next.js+Supabase, Django, Express+Postgres, Firebase), provide stack-specific code examples where useful.