# ADR 002 — Devise 2.2.4 for authentication

- Date: 2013-05-22
- Commit: `0ba7124` (pre-rewrite `aa303c93`)
- Status: accepted (frozen)

## Context

Loan applications are sensitive per-user data, so the app needs accounts:
registration, session management, and password recovery. In the Rails 3
era the ecosystem default was Devise versus the lighter
has_secure_password + hand-rolled sessions.

## Decision

Use **Devise 2.2.4** (with `bcrypt-ruby ~> 3.0.0`) and enable these
modules on `User`:

- `database_authenticatable`, `registerable`, `validatable`
- `recoverable` (reset password tokens)
- `rememberable` (remember-me cookies)
- `trackable` (sign-in counts, timestamps, IPs)

Confirmed/lockable/token/omniauthable modules were left commented out.
Additionally a custom route `get '/sign_out' => 'devise/sessions#destroy'`
exposes sign-out over **GET**, and the home page links to it.

## Consequences

- Full auth stack (views included by the gem, locales wired via
  `devise.en.yml`) for almost no code; `attr_accessible` whitelists
  email/password/remember_me.
- GET-based sign-out violates REST and is CSRF-friendlier to attackers —
  a known anti-pattern, kept anyway because the demo UI uses a plain
  link.
- Devise 2.2.4 predates the 2013 `RESET PASSWORD`/timing CVE fixes era of
  churn; pinned versions are vulnerable by today's standards.
- Any future controller can gate access with
  `before_filter :authenticate_user!` — the standard Devise contract.
