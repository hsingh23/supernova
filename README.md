# Supernova

Supernova is a small Ruby on Rails 3.2 web application for collecting
**loan applications** from registered users. A user signs up with an email
and password (Devise), and can then submit loan applications carrying the
requested amount, term count, SSN, and mailing address.

It was scaffolded in May 2013 and currently contains the authentication and
domain-model foundation: two models (`User`, `LoanApplication`), Devise
routes, and a Haml-rendered home page. The loan-application entry flow
(controllers/views for creating applications) had not been built yet at the
last commit.

> Historical note: this README previously contained the stock `rails new`
> boilerplate (generic Rails/MVC explanations and directory tour). That
> content is superseded here; the upstream Rails guides cover the same
> material if you need it.

## Features

- **Email/password authentication** via Devise 2.2.4 — registration, login,
  logout, password recovery, remember-me, and sign-in tracking
- **Custom sign-out path** — `GET /sign_out` in addition to Devise's
  standard `DELETE /users/sign_out`
- **Loan application domain model** — `LoanApplication` belongs to `User`
  with amount, terms, SSN, and address fields
- **Haml views** — the home screen and application layout are written in
  Haml 4
- **RSpec test harness** — model specs wired up (currently pending stubs)

## Stack

| Component  | Version / choice                    |
|------------|-------------------------------------|
| Language   | Ruby (1.9-era)                      |
| Framework  | Rails 3.2.13                        |
| Database   | SQLite3 (all environments)          |
| Auth       | Devise 2.2.4 + bcrypt-ruby ~3.0     |
| Views      | Haml 4.0.3, ERB fallback            |
| JS runtime | therubyracer + execjs               |
| Assets     | Sprockets (sass-rails, uglifier), vendored jQuery |
| Testing    | RSpec (rspec-rails)                 |
| Console    | pry-rails (dev/test)                |

## Quickstart

Requires a Ruby version compatible with Rails 3.2 (e.g. 1.9.3) and the
`bundler` gem.

```sh
gem install bundler
bundle install            # or: bundle _1.x_ install for old Rubies
bundle exec rake db:migrate   # creates db/development.sqlite3
bundle exec rails server
```

Then open <http://localhost:3000/>:

1. You land on the home page (`HomeController#index`, Haml template).
2. Sign up at `/users/sign_up`, sign in at `/users/sign_in`.
3. Use the "Sign me out" link (the custom `/sign_out` route) to log out.

Run the test suite:

```sh
bundle exec rspec
```

## Project structure

```
app/
  controllers/    ApplicationController (CSRF protection), HomeController
  models/         User (Devise), LoanApplication (belongs_to :user)
  views/
    home/         index.html.haml, application.html.haml (Haml layout)
    layouts/      application.html.erb (default Rails layout, unused by home)
config/
  routes.rb       devise_for :users, root -> home#index, GET /sign_out
  database.yml    SQLite3 for development/test/production
  initializers/   devise.rb, secret_token.rb, session_store.rb, ...
db/
  migrate/        devise_create_users, create_loan_applications
  schema.rb       authoritative schema (version 20130522160034)
spec/             spec_helper.rb + pending model specs
vendor/assets/    vendored jquery.js
```

## Configuration

No environment variables are required. Configuration lives in standard
Rails files:

- `config/database.yml` — database names/paths per environment (SQLite3)
- `config/initializers/secret_token.rb` — cookie-signing secret
- `config/initializers/devise.rb` — Devise settings (stretches, pepper)

## Known issues

- The `loan_applications.loan_ammount` column name is a typo (double *m*);
  it is preserved throughout the schema and migration.
- Dependency set is from 2013 and carries known CVEs (GitHub Dependabot
  reports alerts on this repo). Do not deploy as-is.
- `spec/` model specs are pending stubs; there is no real test coverage.
- The committed `secret_token.rb` is a real secret in version control;
  rotate before any reuse of this codebase.
