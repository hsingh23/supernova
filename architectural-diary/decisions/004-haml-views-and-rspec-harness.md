# ADR 004 — Haml views, RSpec harness, minimal home screen

- Date: 2013-05-22
- Commit: `0ba7124` (pre-rewrite `aa303c93`)
- Status: accepted (frozen)

## Context

The scaffold's ERB layout needed replacing with the team's preferred
template engine, and the Rails test-unit railtie had been disabled, so a
test framework had to be wired in before any models existed.

## Decision

1. **Haml 4.0.3** for view templates. A dedicated
   `app/views/home/application.html.haml` layout accompanies the home
   screen; the root route renders `home/index.html.haml` — a heading
   ("Welcome to Supernova") and a sign-out link. jQuery is vendored at
   `vendor/assets/javascripts/jquery.js` rather than pulled from a CDN.
2. **RSpec** (`rspec-rails`, `.rspec` with `--color`,
   `spec/spec_helper.rb`) with generated-but-pending specs for `User` and
   `LoanApplication`.
3. Gemfile hygiene in the same commit: `sqlite3`, `rspec-rails`,
   `pry-rails` moved into `group :development, :test`, `Gemfile.lock`
   committed, README converted to markdown.

## Consequences

- Two layouts coexist: `app/views/layouts/application.html.erb` (stock,
  used by anything that doesn't find the Haml one) and the Haml layout
  under `app/views/home/`. Confusing but functional.
- The Haml layout calls `stylesheet_linktag` (missing underscore) so
  `application.css` silently never loads on the home page.
- Specs are placeholders (`pending "add some examples"`), so the suite
  passes vacuously — it verifies the harness, not behavior.
- Vendored jQuery pins the app to a 2013 1.x release with known XSS CVEs;
  Sprockets will happily serve it.
