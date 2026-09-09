# ADR 001 — Rails 3.2 on SQLite with the asset pipeline

- Date: 2013-05-22
- Commit: `b18b008` (stock scaffold; pre-rewrite `ec1ffc61`)
- Status: accepted (frozen)

## Context

A new web project ("Supernova") needed a foundation in May 2013. Rails
3.2.13 was the current stable release. The developer worked at a company
whose domain is consumer lending (author email domain), so a
database-backed MVC framework with mature ORM and auth ecosystems was the
obvious starting point.

## Decision

Scaffold with `rails new` on Rails 3.2.13 defaults:

- **SQLite3** as the database for *all* environments (production `pg`
  commented out in the Gemfile — a swap intended but never made)
- **Sprockets asset pipeline** (`sass-rails`, `uglifier`) with
  `execjs` + `therubyracer` to provide a JavaScript runtime
- Rails-test railtie commented out in `config/application.rb`,
  clearing the path for RSpec later
- `config.active_record.whitelist_attributes = true` (the Rails 3
  mass-assignment hardening response to the GitHub incident era)

## Consequences

- Zero-config boot: `bundle install && rake db:migrate && rails server`
  works with no external services.
- Production-on-SQLite was never revisited; deploying would require the
  Gemfile swap plus a schema load.
- therubyracer is obsolete (libv8 binding) and blocks modern installs;
  it's one of the main reasons the bundle won't resolve on current Ruby.
- Whitelist mode means later models silently drop mass-assignment of any
  attribute not listed in `attr_accessible` — a trap for future agents.
