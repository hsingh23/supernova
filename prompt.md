# prompt.md — One-Shot Recreation Prompt for Supernova

Give this entire document to a competent coding agent (or developer) with
an empty directory; the result should be a functionally identical
application. It encodes every design decision recoverable from the
original 2013 codebase.

---

## Goal

Build **Supernova**, a Rails web application where users register with
email/password and submit loan applications (amount, terms, SSN, mailing
address). Recreates the state of the original repo at commit `0ba7124`
(2013-05-22): an authentication + domain-model foundation with a Haml
home screen. The loan-application CRUD flow is intentionally *not* part
of this scope — only its data model is.

## Stack (fixed)

- Ruby (1.9-era) + Rails **3.2.13**, application module
  `Supernova::Application`
- SQLite3 for development, test, and production; `pg` commented out of
  the production group
- Devise **2.2.4** + `bcrypt-ruby ~> 3.0.0`
- Haml **4.0.3** for hand-written views
- Asset pipeline: `sass-rails ~> 3.2.3`, `uglifier >= 1.0.3`, `execjs` +
  `therubyracer` as JS runtime; vendored jQuery (1.x era) at
  `vendor/assets/javascripts/jquery.js`
- Testing: `rspec-rails` (dev/test), `.rspec` = `--color`
- Console: `pry-rails` (dev/test)

*(Modern substitution is acceptable only if the agent cannot install
legacy Ruby — replicate behavior, not versions, in that case.)*

## Phased build order

1. **Scaffold**: `rails new` with Rails 3.2.13 defaults; comment out
   `rails/test_unit/railtie` in `config/application.rb`; enable
   `config.active_record.whitelist_attributes = true`;
   `config.filter_parameters += [:password]`; asset pipeline on,
   `config.assets.version = '1.0'`.
2. **Auth**: install Devise, generate the `User` model with modules
   `database_authenticatable, registerable, recoverable, rememberable,
   trackable, validatable`; run its migration.
3. **Domain**: create the `LoanApplication` model + migration (schema
   below).
4. **Routes**: root + Devise + custom sign-out (below).
5. **Home screen**: `HomeController` + Haml views + Haml layout.
6. **Test harness**: `.rspec`, `spec_helper.rb`, pending specs for both
   models.
7. **Gemfile hygiene**: group sqlite3/rspec-rails/pry-rails under
   `:development, :test`; commit `Gemfile.lock`.

## Data model

```
users                                   loan_applications
  email                  string NOT NULL ""    user_id       integer
  encrypted_password     string NOT NULL ""    loan_ammount  decimal   -- sic, double m
  reset_password_token   string (uniq idx)     terms         integer
  reset_password_sent_at datetime              ssn           string    -- plain text
  remember_created_at    datetime              postal_code   string
  sign_in_count          integer  default 0    address       string
  current_sign_in_at     datetime              state         string
  last_sign_in_at        datetime              created_at    datetime
  current_sign_in_ip     string                updated_at    datetime
  last_sign_in_ip        string
  created_at/updated_at  datetime
  -- unique indexes on email and reset_password_token
```

Model code: `User has_many :loan_applications`,
`attr_accessible :email, :password, :password_confirmation, :remember_me`;
`LoanApplication belongs_to :user` and nothing else — no validations, no
foreign-key index, no `dependent` option. The `loan_applications`
migration uses explicit `up`/`down` methods.

## APIs / routes (complete list)

| HTTP | Path | Handler | Purpose |
|------|------|---------|---------|
| GET  | `/` | `HomeController#index` | Home page (Haml) |
| GET  | `/sign_out` | `devise/sessions#destroy` | Custom GET sign-out |
| *    | `/users/*` | Devise | sign_in, sign_up, password recovery (standard Devise route set via `devise_for :users`) |

Routes file essentials:

```ruby
Supernova::Application.routes.draw do
  devise_for :users
  root to: "home#index"
  get '/sign_out' => "devise/sessions#destroy", as: :sign_out
end
```

`HomeController#index` is an empty action rendering
`app/views/home/index.html.haml`:

```haml
%h1 Welcome to Supernova
= link_to "Sign me out", sign_out_path
```

Haml layout `app/views/home/application.html.haml` (note: reproduces the
original `stylesheet_linktag` typo — keep or consciously fix):

```haml
!!!
%html
  %head
    %title Supernova
    = stylesheet_linktag "application", media: :all
    = javascript_include_tag 'application'
    = csrf_meta_tags
  %body
    = yield
```

`ApplicationController` is bare: `protect_from_forgery` only.

## All design decisions (must-match)

1. SQLite everywhere; production postgres left as a comment.
2. Devise modules exactly: database_authenticatable, registerable,
   recoverable, rememberable, trackable, validatable. Confirmable /
   lockable / timeoutable / omniauthable commented out.
3. Sign-out exposed over **GET** at `/sign_out` (non-RESTful,
   deliberate).
4. Mass-assignment whitelist mode ON; only the four User attrs are
   accessible; LoanApplication has none.
5. Haml for new views; stock ERB layout left in place alongside the Haml
   one.
6. jQuery vendored, not CDN.
7. RSpec (not Test::Unit); model specs are pending stubs.
8. `loan_ammount` misspelling preserved end-to-end (migration, schema).
9. SSN stored as a plain string column (recreate as-is for fidelity;
   flag in code comment that this must be encrypted before real use).
10. Devise initializer defaults; `config.stretches = Rails.env.test? ? 1
    : 10`; generate a fresh `secret_token` — never commit a reused one.

## Acceptance criteria

1. `bundle install && bundle exec rake db:migrate` succeeds and builds
   both tables exactly as specified (verify `db/schema.rb` matches the
   data model above, including the `loan_ammount` column name).
2. `bundle exec rails server`:
   - `GET /` returns 200 with "Welcome to Supernova" and a sign-out
     link.
   - `/users/sign_up` -> register -> signed in; `GET /sign_out` signs
     out.
   - Password recovery pages render.
3. `bundle exec rspec` runs and passes (pending stubs count as passing).
4. `bundle exec rake routes` lists exactly: the home root, the custom
   `sign_out`, and the Devise `users/*` set — nothing else.
5. `rails console`: `User.new(...).save` and
   `LoanApplication.new(user_id: u.id, ...)` persist; assigning
   unlisted attributes to `User` via mass assignment is ignored
   (whitelist mode proof).
6. No controller/view exists for creating loan applications — scope
   ends at the data model.
