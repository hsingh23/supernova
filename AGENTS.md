# AGENTS.md — Agent Working Guide for Supernova

Guidance for coding agents (and humans) working in this repository.

## What this is

A 2013-era Rails 3.2.13 loan-application web app: Devise authentication,
`User`/`LoanApplication` models, Haml home screen, SQLite3 storage, RSpec
harness. Small codebase (~2 commits of history); the app layer beyond the
home page was never built.

## Commands

```sh
bundle install                       # install dependencies (needs old Ruby, e.g. 1.9.3)
bundle exec rake db:migrate          # apply migrations to db/development.sqlite3
bundle exec rake db:test:prepare     # (old-style) clone schema into test db
bundle exec rails server             # run the app at http://localhost:3000
bundle exec rails console            # pry-rails console in dev
bundle exec rspec                    # run the (pending) test suite
bundle exec rake routes              # inspect the routing table
bundle exec rake db:rollback         # undo the last migration
```

Note: `rails`/`rake`/`rspec` must be run through `bundle exec` because all
gems live in the bundle; the repo uses the Rails 3.2 `script/rails`
entrypoint rather than the modern `bin/` stubs.

## Architecture map

```
config/routes.rb
  devise_for :users                       # /users/sign_in, /sign_up, /sign_out (DELETE), password recovery
  root to: "home#index"                   # HomeController#index -> app/views/home/index.html.haml
  get '/sign_out' => "devise/sessions#destroy"   # custom GET-based sign-out

app/models/user.rb
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable
  attr_accessible :email, :password, :password_confirmation, :remember_me
  has_many :loan_applications

app/models/loan_application.rb
  belongs_to :user
  # columns: user_id, loan_ammount (typo, intentional legacy), terms, ssn,
  #          postal_code, address, state

app/controllers/application_controller.rb   # protect_from_forgery only
app/controllers/home_controller.rb          # empty index action
app/views/home/application.html.haml        # Haml layout used by home views
app/views/home/index.html.haml              # "Welcome to Supernova" + sign-out link
```

Key config: `config/application.rb` enables
`config.active_record.whitelist_attributes = true` (Rails 3 mass-assignment
protection — any new model attribute must be added to `attr_accessible` or
assignments will be silently dropped), filters `:password` from logs, and
enables the asset pipeline (version `'1.0'`).

## Conventions

- **Conventional Commits** subjects: imperative mood, <=72 chars,
  `type(scope): summary`. (The two legacy commits were rewritten to this
  style on 2026-09-08 — see CHANGELOG.md.)
- **Views**: new user-facing screens should use Haml (matches
  `home/*.html.haml`). `app/views/layouts/application.html.erb` is the
  Rails-generated default and is not what `home/application.html.haml`
  renders.
- **Models**: whitelist attributes with `attr_accessible` (whitelist mode
  is on globally).
- **Migrations**: classic `up`/`down` style is used in
  `create_loan_applications`; either that or `change` is acceptable.
- **Tests**: RSpec with `--color` (`.rspec`); model specs belong in
  `spec/models/`.

## Gotchas

- **`loan_ammount` is misspelled** in the schema/migration. Renaming it
  requires a migration; do not "fix" only the model code.
- **Committed secrets**: `config/initializers/secret_token.rb` contains a
  live cookie-signing secret, and `config/initializers/devise.rb` has a
  commented-out pepper. Never copy these values into docs, code, or logs;
  rotate before reuse.
- **SSN is stored as plain `string`** — no encryption. Any feature work
  here has serious compliance implications; do not extend without
  encryption at rest.
- **Ancient dependencies** (Rails 3.2.13, Devise 2.2.4, Haml 4.0.3,
  therubyracer): 90+ Dependabot alerts. Bundler may refuse modern
  resolution; you may need `bundle _1.17.x_ install` and an old Ruby via a
  version manager. Do not attempt blind `bundle update`.
- **`stylesheet_linktag`** in `app/views/home/application.html.haml` is a
  typo (missing underscore) — the Haml layout does not actually load
  `application.css`. Fix if touching views.
- **Gemfile groups**: `sqlite3`, `rspec-rails`, `pry-rails` are
  development/test only; production group is empty (pg commented out).
- **Vendored jQuery** lives in `vendor/assets/javascripts/jquery.js`
  (9.4k lines, v1.x era) — don't hand-edit.

## Verifying changes

1. `bundle exec rspec` — suite is green-trivial (pending stubs only), so
   also smoke-test by hand:
2. `bundle exec rake db:migrate && bundle exec rails server`, then:
   - `GET /` renders "Welcome to Supernova"
   - `/users/sign_up` -> create account -> redirect/auth works
   - `/sign_out` (GET) logs out
3. `bundle exec rake routes` — routing changes should be reflected here
   before/after.
4. For schema changes: `bundle exec rake db:migrate && bundle exec rake
   db:rollback && bundle exec rake db:migrate` to prove reversibility.

## Pointers

- `CHANGELOG.md` — per-commit history (newest first) + rewrite note
- `architectural-diary/main.md` — narrative history of the architecture
- `architectural-diary/decisions/` — numbered architecture decision records
- `prompt.md` — one-shot recreation prompt for this exact codebase
