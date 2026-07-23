# Board Code (Meal Type) Support — Design

**Date**: 2026-07-23
**Status**: Pending user review

## Goal

Align `platform_client` with the Kabuk Platform's multi-board (boarding/meal type)
support (platform spec: `kabuk-platform/docs/superpowers/specs/2026-07-02-multi-board-support-design.md`,
shipped in platform commit `d8fd5505`). Consumers of the gem can pass `board_code` to
`check_availability` and `check_rate`. Omitting it preserves today's behavior exactly.

## Scope

Gem only. No changes to `monorepo/apps/api` — it keeps working unchanged (the platform
defaults `check_rate` to `room_only` when the param is absent) and adopts `board_code`
in its own follow-up work.

## Platform API contract being wrapped

- `GET /api/check_availability`: optional `board_code` query param (string enum name).
  Omitted → one best-price row per board the property offers. Present → rows filtered to
  that board.
- `GET /api/check_rate`: optional `board_code` query param. Omitted → server defaults to
  `room_only`. Present → the returned single rate targets that board.
- Valid values (7): `room_only`, `breakfast`, `lunch`, `dinner`, `half_board`,
  `full_board`, `all_inclusive` (`unknown` is rejected by the platform).
- While the platform's `multi_board_support_enabled` feature flag is off, non-`room_only`
  values get a 422 validation error on both endpoints.
- Booking API is unchanged (`rate_key` carries the board implicitly).

## Design

### 1. Request classes

- `PlatformClient::Requests::Rate` (`lib/platform_client/requests/rate.rb`): add
  `attribute :board_code, :string`. No default, no validation (pass-through — the server
  is the authority on valid values, and `Requests::Base#call` does not run validations
  at runtime anyway).
- `PlatformClient::Requests::Availabilities`
  (`lib/platform_client/requests/availabilities.rb`): add
  `attribute :board_code, :string`, same treatment.

Both endpoints are GET, and `Base#params` already applies `compact_blank`, so a nil
`board_code` is not sent at all and the server default applies. No changes to `Base`,
`EndPoint`, or `Client`.

### 2. Facade (`lib/platform_client/requests.rb`)

- `Requests.check_availability(..., board_code: nil)` — new keyword arg, passed through
  to `Availabilities.call`.
- `Requests.check_rate(..., board_code: nil, ...)` — new keyword arg, passed through to
  `Rate.call`.
- YARD docs on both methods list the seven valid values, describe omitted-param behavior
  per endpoint, and note that non-`room_only` values require the platform's multi-board
  feature flag (422 → `Errors::ValidationError` otherwise).

No `BOARD_CODES` constant is added (deliberate: the gem does not duplicate server
policy; values are documented in YARD only).

### 3. Errors — no code change

- The platform's new `NoBoardRateFound` error subclasses `RateUnavailable`, so it
  arrives with error code `RATE_UNAVAILABLE` and reason `no_board_rate`. The existing
  `ERROR_CODE_MAP` already raises `Errors::RateUnavailableError` for it; callers
  distinguish the board case via the existing `ClientError#error_reason` accessor.
- Invalid `board_code` / flag-off 422s arrive as `VALIDATION_ERROR` →
  `Errors::ValidationError` (already mapped).

### 4. Responses — no code change

Response classes are thin wrappers over parsed JSON; `board_code` is already emitted by
the platform's serializers and flows through `Responses::Rate#data` /
`Responses::Availabilities#data` untouched.

### 5. Testing

Following existing spec patterns:

- Request-class specs (`spec/platform_client/requests/rates_spec.rb`,
  `availabilities_spec.rb`): `board_code` is included in query params when set and
  omitted when nil.
- VCR-backed specs with new hand-crafted cassettes in `spec/vcr_cassettes/shopping/`
  (per the recording procedure in
  `spec/platform_client/requests/support_helpers.rb`):
  - `check_rate` with `board_code: 'breakfast'` — response echoes that board.
  - `check_availability` without `board_code` — response contains rows for multiple
    boards.
  - `check_rate` with a non-`room_only` board while the platform flag is off — 422 with
    a structured `VALIDATION_ERROR` body → raises `Errors::ValidationError`.
- Regression: full existing suite passes; requests without `board_code` produce
  byte-identical HTTP requests to today.

### 6. Release

- Bump `PlatformClient::VERSION` `0.2.0` → `0.3.0` (additive, backward compatible).
- CHANGELOG entry describing the new optional parameter.

## Rejected alternatives

- **Client-side inclusion validation / `BOARD_CODES` constant**: rejected to avoid the
  gem drifting from the server if board types change; the server already returns a clear
  422, and the gem's request validations are not enforced at runtime.
- **Explicit `room_only` default on `check_rate`**: redundant — it encodes server policy
  in the gem and changes every existing consumer's request for no benefit.
