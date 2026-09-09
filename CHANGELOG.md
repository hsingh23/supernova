# Changelog

All notable changes to this project are documented here, newest first.
This project adheres to [Keep a Changelog](https://keepachangelog.com/) conventions.

> **History rewrite note (2026-09-08):** the two original commit messages
> ("Initial ruby app", "app changes") were rewritten in place via a
> messages-only `git filter-branch` to follow Conventional Commits style.
> File trees, authors, and dates are unchanged; only commit messages and
> therefore commit hashes differ from the pre-rewrite history
> (`ec1ffc61` -> `b18b008`, `aa303c93` -> `0ba7124`).

## 2013-05-22 — `0ba7124` — feat: add Devise auth, User and LoanApplication models, Haml home views

Second and latest commit; builds the entire application layer on top of the
bare scaffold.

- Integrate Devise 2.2.4: `users` migration (database_authenticatable,
  registerable, recoverable, rememberable, trackable, validatable modules),
  initializer, `devise.en.yml` locale, `devise_for :users` routes, and a
  custom `GET /sign_out` route mapped to `devise/sessions#destroy`
- Add `User` model with `has_many :loan_applications` and
  `attr_accessible :email, :password, :password_confirmation, :remember_me`
- Add `LoanApplication` model (`belongs_to :user`) backed by the
  `create_loan_applications` migration with columns `user_id`,
  `loan_ammount` (sic — typo preserved in schema), `terms`, `ssn`,
  `postal_code`, `address`, `state`, timestamps
- Add `HomeController#index` with Haml views (`home/index.html.haml` shows a
  welcome heading and sign-out link; `home/application.html.haml` layout) and
  `root to: "home#index"`
- Restructure Gemfile: move `sqlite3`, `rspec-rails`, `pry-rails` into the
  `:development, :test` groups; add `execjs`, `therubyracer`, `haml`,
  `devise`, `bcrypt-ruby`; commit `Gemfile.lock`
- Install RSpec scaffolding: `.rspec` (color), `spec/spec_helper.rb`, pending
  model specs for `User` and `LoanApplication`
- Vendor `jquery.js` under `vendor/assets/javascripts/`
- Replace the stock `README.rdoc` boilerplate with `README.md`

## 2013-05-22 — `b18b008` — chore: scaffold initial Rails 3.2.13 application skeleton

First commit: the untouched output of `rails new`.

- Stock Rails 3.2.13 application skeleton for the `Supernova::Application`
  module: default directory layout (`app/`, `config/`, `db/`, `public/`,
  `script/`, `vendor/`)
- Gemfile pinning `rails 3.2.13` with the asset pipeline group
  (`sass-rails`, `uglifier`) and SQLite as the default database
- Default environment configs (`development`/`test`/`production`),
  initializers, routes, `application.html.erb` layout, error pages
  (`404/422/500`), and `.gitignore`
- Boilerplate `README.rdoc` and `.gitkeep` placeholders for mailers, models,
  and assets — no custom application logic
