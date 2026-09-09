# Architectural Diary — Supernova

A narrative history of how this codebase came to look the way it does.
Written retroactively on 2026-09-08 from git history (2 commits, both
2013-05-22, author Harsh Singh). Cross-references:
[decisions/](decisions/) contains the numbered decision records.

## Timeline

### Phase 0 — stock scaffold (`b18b008`, 2013-05-22 09:43)

The repository begins life as the untouched output of `rails new` for a
Rails 3.2.13 application named **Supernova** (`Supernova::Application` in
`config/application.rb`). Everything is default: SQLite3 database, ERB
layout, asset pipeline with `sass-rails`/`uglifier`, commented-out
Rails-test scaffolding (the `rails/test_unit` railtie is even commented
out of `application.rb`, foreshadowing the later switch to RSpec), and the
boilerplate `README.rdoc`. Notably the scaffold also ships
`config/initializers/secret_token.rb` with a generated secret committed to
version control — standard practice at the time, a liability now.

### Phase 1 — the whole app in one commit (`0ba7124`, 2013-05-22 11:24)

Ninety minutes later, everything application-specific lands in a single
"app changes" commit (message since rewritten; original subject was
literally `app changes`). In one sweep it:

- brings in **Devise 2.2.4** — the standard Rails 3 authentication answer —
  with the full `users` table (auth + recoverable + rememberable +
  trackable columns), initializer, and locales;
- defines the domain: a `User` who `has_many :loan_applications`, and a
  `LoanApplication` with `user_id`, `loan_ammount` (typo included), `terms`,
  `ssn`, `postal_code`, `address`, `state`;
- adds the first screen: `HomeController#index` rendered in **Haml**
  (`app/views/home/`), showing a welcome heading and a sign-out link, wired
  as the root route plus a custom `GET /sign_out`;
- reorganizes the Gemfile into proper groups (sqlite3/rspec/pry to
  development+test), commits `Gemfile.lock`, vendors jQuery, replaces the
  README with markdown, and sets up RSpec with pending model specs.

### State at last commit

An authentication-and-schema foundation with no loan-application entry
flow: there is no `LoanApplicationsController`, no form for creating an
application, and no validations on `LoanApplication` beyond the bare
association. The home view even contains a `stylesheet_linktag` typo
(missing underscore), so the Haml layout never loads the stylesheet. The
remote also carries ~45 `snyk-fix/*` branches, evidence that automated
dependency-remediation was pointed at the repo at some point, but none of
it was ever merged to master.

### 2026-09-08 — documentation pass

Commit messages were rewritten messages-only (originals "Initial ruby app"
/ "app changes" -> conventional-commit format), the tree untouched, and
this documentation set (README, AGENTS.md, CHANGELOG, diary, prompt.md)
was added. See CHANGELOG.md for the hash mapping.

## Recurring themes

- **Batteries-included Rails 3 defaults** over hand-rolled anything:
  Devise for auth, Active Record migrations for schema, Sprockets for
  assets.
- **Single mega-commit iteration** — the entire app layer landed at once,
  making per-change archaeology impossible; this diary is necessarily
  coarse-grained.
- **Bugs frozen in amber** — `loan_ammount`, `stylesheet_linktag`,
  committed `secret_token.rb`, plain-text SSN column — all small, all
  never revisited because development stopped the same day it started.
