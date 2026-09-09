# ADR 003 — Loan application domain model

- Date: 2013-05-22
- Commit: `0ba7124` (pre-rewrite `aa303c93`)
- Status: accepted (frozen)

## Context

The product concept: a registered user submits loan applications. The
schema needed to capture what a lender would ask for at intake — amount,
term, identity, and address.

## Decision

Two Active Record models:

```
User                                  LoanApplication
  devise modules ...                    belongs_to :user
  has_many :loan_applications           # columns:
  attr_accessible :email, ...           #   user_id      integer
                                       #   loan_ammount decimal  (sic)
                                       #   terms        integer
                                       #   ssn          string
                                       #   postal_code  string
                                       #   address      string
                                       #   state        string
                                       #   timestamps
```

- Migration written with explicit `up`/`down` (the commented-out `change`
  version is left in the file).
- No validations, no indexes on `loan_applications.user_id`, no
  `dependent` option on the association.

## Consequences

- The association is navigable both ways
  (`user.loan_applications`, `loan_application.user`) but with **no
  foreign-key index** — fine at toy scale, slow at any real scale.
- `ssn` is a **plain string column**: no encryption, no masking. This is
  the single riskiest decision in the codebase; any revival must encrypt
  at rest and mask in views/logs before touching real data.
- `loan_ammount` (double *m*) is frozen into schema and migration; code
  must reference the misspelled column or migrate a rename.
- No controller/view exists to create `LoanApplication` records — the
  model is a foundation awaiting its CRUD layer.
