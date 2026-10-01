# Board Code (Meal Type) Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an optional pass-through `board_code` parameter to `check_rate` and `check_availability` in the platform_client gem, aligning it with the Kabuk Platform's multi-board (meal type) support.

**Architecture:** Two request classes each gain one unvalidated `ActiveModel` string attribute; the `Requests` facade gains matching `board_code: nil` keyword args. Because both endpoints are GET and `Requests::Base#params` applies `compact_blank`, a nil `board_code` is never sent and server defaults apply. Errors and responses need no code changes.

**Tech Stack:** Ruby 3.3.5, ActiveModel, Faraday, RSpec, VCR/WebMock, RuboCop.

**Spec:** `docs/superpowers/specs/2026-07-23-board-code-support-design.md`

## Global Constraints

- Valid board values (documented in YARD only, never validated client-side): `room_only`, `breakfast`, `lunch`, `dinner`, `half_board`, `full_board`, `all_inclusive`.
- No `BOARD_CODES` constant, no client-side inclusion validation, no new dependencies.
- Requests without `board_code` must produce byte-identical HTTP requests to today (existing VCR cassettes must keep passing unmodified — VCR matches on method + full URI).
- Style: single quotes, trailing commas in multiline hashes, `# frozen_string_literal: true`. `bundle exec rubocop` must pass.
- VCR cassette URIs list query params **alphabetically** (WebMock normalizes them); a hand-crafted cassette with unsorted params will never match.
- All new cassettes go in `spec/vcr_cassettes/shopping/`.

## Pre-existing WIP (handle before Task 1)

The branch `feat/board-code-support` carries two uncommitted items that predate this work and are NOT part of it:

1. A staged edit to `lib/platform_client/requests.rb` changing `check_availability`'s `adults_count` default from `1` to `nil` (doc + signature fix).
2. An orphaned untracked cassette `spec/vcr_cassettes/shopping/check_rate_check_in_date_past.yml` (referenced by no spec).

**Step 0.1:** Commit the staged edit as its own commit so board_code commits stay clean:

```bash
git commit -m "fix: default check_availability adults_count to nil (all occupancies)" -- lib/platform_client/requests.rb
```

**Step 0.2:** Leave the untracked cassette untouched (it belongs to the user's separate WIP). Never `git add -A` / `git add .` in this plan — always add explicit paths.

The plan's code blocks for `requests.rb` reflect the file state AFTER step 0.1 (i.e. `adults_count: nil`).

---

### Task 1: `board_code` on check_rate

**Files:**
- Modify: `lib/platform_client/requests/rate.rb` (attribute block, after line 13 `attribute :country_code, :string`)
- Modify: `lib/platform_client/requests.rb` (`.check_rate`, lines ~112–127)
- Test: `spec/platform_client/requests/rates_spec.rb` (append inside top-level describe)
- Test: `spec/platform_client/requests_spec.rb` (append inside `describe '.check_rate'` → `context 'with valid parameters'`)
- Create: `spec/vcr_cassettes/shopping/check_rate_with_board_code.yml`

**Interfaces:**
- Consumes: existing `PlatformClient::Requests::Rate` / `Requests.check_rate` (see current files).
- Produces: `Requests.check_rate(property_code:, room_code:, check_in_date:, check_out_date:, country_code:, adults_count: 1, nationality: 'JP', language: 'en-US', board_code: nil, customer_session_id: nil)` and `Requests::Rate` with a `board_code` string attribute. Task 3 relies on this exact facade signature.

- [ ] **Step 1: Create the VCR cassette**

Create `spec/vcr_cassettes/shopping/check_rate_with_board_code.yml` with exactly:

```yaml
---
http_interactions:
- request:
    method: get
    uri: https://kabuk-platform.com/api/check_rate?adults_count=1&board_code=breakfast&check_in_date=2025-01-23&check_out_date=2025-01-25&country_code=JP&language=en-US&nationality=JP&property_code=bk60&room_code=104
    body:
      encoding: US-ASCII
      string: ''
    headers:
      Content-Type:
      - application/json
      Accept-Encoding:
      - gzip
      User-Agent:
      - API Client for Kabuk Platform -
      Authorization:
      - Bearer <BEARER_TOKEN>
      Accept:
      - "*/*"
  response:
    status:
      code: 200
      message: OK
    headers:
      Content-Type:
      - application/json; charset=utf-8
      X-Request-Id:
      - 7dfeda8e-79a2-44dd-a6d8-2c8135e44701
      X-Customer-Session-Id:
      - 019782f9-34bd-7f74-bc39-d2d6a338dc86
    body:
      encoding: UTF-8
      string: '{"rate_key":"9a11c790-13cd-4c1e-bfe3-1fdc7e67c401","net":"12433.10","available_rooms":2,"board_code":"breakfast","non_refundable":false,"cancellation_remarks":"This
        policy is fully refundable","supplier_description":"Standard - 1 Queen Bed - Breakfast
        included","check_in_date":"2025-01-23","check_out_date":"2025-01-25","room_name":"Harmony
        Johnson I","room_code":"104","check_in_instructions":null,"hotel_fees":null,"cancellation_policies":[{"date_from":"2025-01-21","date_to":"2025-01-24","percent":0.0,"amount":"0.0"}]}'
  recorded_at: Wed, 23 Jul 2026 04:00:00 GMT
recorded_with: VCR 6.3.1
```

- [ ] **Step 2: Write the failing tests**

In `spec/platform_client/requests_spec.rb`, inside `describe '.check_rate'` → `context 'with valid parameters'`, after the `'with non-japanese nationality'` context, add:

```ruby
      context 'with board_code' do
        it 'sends board_code and returns the rate for the requested boarding type', vcr: { cassette_name: 'shopping/check_rate_with_board_code' } do
          response = described_class.check_rate(
            property_code: 'bk60',
            room_code: '104',
            check_in_date: '2025-01-23',
            check_out_date: '2025-01-25',
            adults_count: 1,
            country_code: 'JP',
            board_code: 'breakfast'
          )
          expect(response).to be_a PlatformClient::Responses::Rate

          rate = response.data
          expect(rate).to be_a Hash
          expect(rate['board_code']).to eq 'breakfast'
          expect(rate.keys).to contain_exactly('rate_key', 'net', 'available_rooms', 'board_code', 'non_refundable', 'cancellation_remarks', 'supplier_description', 'check_in_date', 'check_out_date', 'room_name', 'room_code', 'cancellation_policies', 'check_in_instructions', 'hotel_fees')
        end
      end
```

In `spec/platform_client/requests/rates_spec.rb`, after the `describe 'validations'` block (still inside the top-level `RSpec.describe`), add:

```ruby
  describe 'request params' do
    it 'includes board_code when set' do
      request = described_class.new(property_code: 'bk60', room_code: '104', board_code: 'breakfast')
      expect(request.send(:params)).to include('board_code' => 'breakfast')
    end

    it 'omits board_code when not set' do
      request = described_class.new(property_code: 'bk60', room_code: '104')
      expect(request.send(:params)).not_to have_key('board_code')
    end
  end
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `bundle exec rspec spec/platform_client/requests_spec.rb -e 'with board_code' spec/platform_client/requests/rates_spec.rb -e 'request params'`
Expected: FAIL — facade spec with `ArgumentError: unknown keyword: :board_code`; params specs with `ActiveModel::UnknownAttributeError` (unknown attribute 'board_code').

- [ ] **Step 4: Implement**

In `lib/platform_client/requests/rate.rb`, after `attribute :country_code, :string` (line 13), add:

```ruby
      attribute :board_code, :string
```

(No validation — pass-through by design; the server owns the valid list.)

In `lib/platform_client/requests.rb`, replace the `.check_rate` YARD `@param customer_session_id` line and method definition:

```ruby
      # @param customer_session_id [String] Customer session ID to track the session, default is nil
      # @param board_code [String] Boarding (meal) type to check the rate for. One of: room_only, breakfast, lunch, dinner,
      #   half_board, full_board, all_inclusive. Default is nil, in which case the Platform defaults to room_only.
      #   Non-room_only values require multi-board support to be enabled on the Platform; otherwise the request
      #   fails with a +PlatformClient::Errors::ValidationError+ (422).
      # @return [PlatformClient::Responses::Rate]
      def check_rate(property_code:, room_code:, check_in_date:, check_out_date:, country_code:, adults_count: 1, nationality: PlatformClient::DEFUAULT_NATIONALITY, language: PlatformClient::DEFAULT_LANGUAGE, board_code: nil, customer_session_id: nil) # rubocop:disable Metrics/ParameterLists
        Rate.call(property_code:, room_code:, check_in_date:, check_out_date:, country_code:, adults_count:, nationality:, language:, board_code:, customer_session_id:)
      end
```

(The `@return` line already exists — shown for placement; the two new lines go between the `customer_session_id` param doc and `@return`.)

- [ ] **Step 5: Run tests to verify they pass**

Run: `bundle exec rspec spec/platform_client/requests_spec.rb spec/platform_client/requests/rates_spec.rb`
Expected: PASS, including all pre-existing examples (proves nil `board_code` still produces the old URIs).

- [ ] **Step 6: Commit**

```bash
git add lib/platform_client/requests/rate.rb lib/platform_client/requests.rb spec/platform_client/requests/rates_spec.rb spec/platform_client/requests_spec.rb spec/vcr_cassettes/shopping/check_rate_with_board_code.yml
git commit -m "feat: add optional board_code param to check_rate"
```

---

### Task 2: `board_code` on check_availability

**Files:**
- Modify: `lib/platform_client/requests/availabilities.rb` (attribute block, after line 11 `attribute :adults_count, :integer`)
- Modify: `lib/platform_client/requests.rb` (`.check_availability`, lines ~99–111)
- Test: `spec/platform_client/requests/availabilities_spec.rb` (append inside top-level describe)
- Test: `spec/platform_client/requests_spec.rb` (append inside `describe '.check_availability'`)
- Create: `spec/vcr_cassettes/shopping/check_availability_with_board_code.yml`
- Create: `spec/vcr_cassettes/shopping/check_availability_multi_board.yml`

**Interfaces:**
- Consumes: nothing from Task 1 (independent change to a sibling class; same facade file).
- Produces: `Requests.check_availability(property_code:, from_date:, to_date:, adults_count: nil, room_code: nil, board_code: nil)` and `Requests::Availabilities` with a `board_code` string attribute.

- [ ] **Step 1: Create the two VCR cassettes**

Create `spec/vcr_cassettes/shopping/check_availability_with_board_code.yml` with exactly:

```yaml
---
http_interactions:
- request:
    method: get
    uri: https://kabuk-platform.com/api/check_availability?adults_count=1&board_code=breakfast&from_date=2025-02-19&property_code=bk60&room_code=104&to_date=2025-02-20
    body:
      encoding: US-ASCII
      string: ''
    headers:
      Content-Type:
      - application/json
      Accept-Encoding:
      - gzip
      User-Agent:
      - API Client for Kabuk Platform -
      Authorization:
      - Bearer <BEARER_TOKEN>
      Accept:
      - "*/*"
  response:
    status:
      code: 200
      message: OK
    headers:
      Content-Type:
      - application/json; charset=utf-8
      X-Request-Id:
      - 5815577c-21bc-46f0-b113-e0dc512a74e4
      X-Customer-Session-Id:
      - 019782fc-ebb3-7af9-8168-c9d0279f4ab9
    body:
      encoding: UTF-8
      string: '[{"date":"2025-02-19","net":"301.20","available_rooms":3,"board_code":"breakfast","non_refundable":false,"cancellation_remarks":"Voluptate
        ratione neque.","supplier_description":"Magnam tenetur iusto asperiores.","room_name":"Harmony
        Johnson I","room_code":"104","adults_count":1,"cancellation_policies":[{"date_from":"2025-02-12","date_to":"2025-02-26","percent":40.32,"amount":"65.54"}]}]'
  recorded_at: Wed, 23 Jul 2026 04:00:00 GMT
recorded_with: VCR 6.3.1
```

Create `spec/vcr_cassettes/shopping/check_availability_multi_board.yml` with exactly:

```yaml
---
http_interactions:
- request:
    method: get
    uri: https://kabuk-platform.com/api/check_availability?adults_count=1&from_date=2025-02-19&property_code=bk60&room_code=104&to_date=2025-02-20
    body:
      encoding: US-ASCII
      string: ''
    headers:
      Content-Type:
      - application/json
      Accept-Encoding:
      - gzip
      User-Agent:
      - API Client for Kabuk Platform -
      Authorization:
      - Bearer <BEARER_TOKEN>
      Accept:
      - "*/*"
  response:
    status:
      code: 200
      message: OK
    headers:
      Content-Type:
      - application/json; charset=utf-8
      X-Request-Id:
      - 6926688d-32cd-47a1-c224-f1ed623b85f5
      X-Customer-Session-Id:
      - 019782fc-ebb3-7af9-8168-c9d0279f4ab9
    body:
      encoding: UTF-8
      string: '[{"date":"2025-02-19","net":"273.47","available_rooms":3,"board_code":"room_only","non_refundable":false,"cancellation_remarks":"Voluptate
        ratione neque.","supplier_description":"Magnam tenetur iusto asperiores.","room_name":"Harmony
        Johnson I","room_code":"104","adults_count":1,"cancellation_policies":[{"date_from":"2025-02-12","date_to":"2025-02-26","percent":40.32,"amount":"65.54"}]},{"date":"2025-02-19","net":"301.20","available_rooms":3,"board_code":"breakfast","non_refundable":false,"cancellation_remarks":"Voluptate
        ratione neque.","supplier_description":"Magnam tenetur iusto asperiores.","room_name":"Harmony
        Johnson I","room_code":"104","adults_count":1,"cancellation_policies":[{"date_from":"2025-02-12","date_to":"2025-02-26","percent":40.32,"amount":"65.54"}]},{"date":"2025-02-19","net":"355.00","available_rooms":2,"board_code":"half_board","non_refundable":false,"cancellation_remarks":"Voluptate
        ratione neque.","supplier_description":"Magnam tenetur iusto asperiores.","room_name":"Harmony
        Johnson I","room_code":"104","adults_count":1,"cancellation_policies":[{"date_from":"2025-02-12","date_to":"2025-02-26","percent":40.32,"amount":"65.54"}]}]'
  recorded_at: Wed, 23 Jul 2026 04:00:00 GMT
recorded_with: VCR 6.3.1
```

- [ ] **Step 2: Write the failing tests**

In `spec/platform_client/requests_spec.rb`, inside `describe '.check_availability'`, after the existing `context 'with valid parameters'`, add:

```ruby
    context 'with board_code filter', vcr: { cassette_name: 'shopping/check_availability_with_board_code' } do
      it 'sends board_code and returns only that boarding type' do
        response = described_class.check_availability(
          property_code: 'bk60',
          room_code: '104',
          from_date: '2025-02-19',
          to_date: '2025-02-20',
          adults_count: 1,
          board_code: 'breakfast'
        )
        expect(response).to be_a PlatformClient::Responses::Availabilities

        availabilities = response.data
        expect(availabilities).to be_a Array
        expect(availabilities.map { |a| a['board_code'] }).to all(eq('breakfast'))
      end
    end

    context 'when the property offers multiple boarding types', vcr: { cassette_name: 'shopping/check_availability_multi_board' } do
      it 'returns one row per boarding type when board_code is omitted' do
        response = described_class.check_availability(
          property_code: 'bk60',
          room_code: '104',
          from_date: '2025-02-19',
          to_date: '2025-02-20',
          adults_count: 1
        )
        expect(response).to be_a PlatformClient::Responses::Availabilities

        availabilities = response.data
        expect(availabilities.size).to eq 3
        expect(availabilities.map { |a| a['board_code'] }).to contain_exactly('room_only', 'breakfast', 'half_board')
        expect(availabilities.sample.keys).to contain_exactly('date', 'net', 'available_rooms', 'board_code', 'non_refundable', 'cancellation_remarks', 'supplier_description', 'room_name', 'room_code', 'adults_count', 'cancellation_policies')
      end
    end
```

In `spec/platform_client/requests/availabilities_spec.rb`, after the `describe 'validations'` block, add:

```ruby
  describe 'request params' do
    it 'includes board_code when set' do
      request = described_class.new(property_code: 'bk60', board_code: 'breakfast')
      expect(request.send(:params)).to include('board_code' => 'breakfast')
    end

    it 'omits board_code when not set' do
      request = described_class.new(property_code: 'bk60')
      expect(request.send(:params)).not_to have_key('board_code')
    end
  end
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `bundle exec rspec spec/platform_client/requests_spec.rb -e 'board' spec/platform_client/requests/availabilities_spec.rb -e 'request params'`
Expected: FAIL — `ArgumentError: unknown keyword: :board_code` / `ActiveModel::UnknownAttributeError`.

- [ ] **Step 4: Implement**

In `lib/platform_client/requests/availabilities.rb`, after `attribute :adults_count, :integer` (line 11), add:

```ruby
      attribute :board_code, :string
```

In `lib/platform_client/requests.rb`, replace the `.check_availability` YARD tail and method definition (note the added `# rubocop:disable Metrics/ParameterLists` — the method now has 6 keyword args):

```ruby
      # @param adults_count [Integer] Number of adults, default is nil to fetch availability for all available occupancies
      # @param board_code [String] Boarding (meal) type filter. One of: room_only, breakfast, lunch, dinner,
      #   half_board, full_board, all_inclusive. Default is nil, in which case the Platform returns one best-price
      #   row per boarding type the property offers. Non-room_only values require multi-board support to be enabled
      #   on the Platform; otherwise the request fails with a +PlatformClient::Errors::ValidationError+ (422).
      #
      # @return [PlatformClient::Responses::Availabilities]
      def check_availability(property_code:, from_date:, to_date:, adults_count: nil, room_code: nil, board_code: nil) # rubocop:disable Metrics/ParameterLists
        Availabilities.call(property_code:, room_code:, from_date:, to_date:, adults_count:, board_code:)
      end
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `bundle exec rspec spec/platform_client/requests_spec.rb spec/platform_client/requests/availabilities_spec.rb`
Expected: PASS, including all pre-existing examples.

- [ ] **Step 6: Commit**

```bash
git add lib/platform_client/requests/availabilities.rb lib/platform_client/requests.rb spec/platform_client/requests/availabilities_spec.rb spec/platform_client/requests_spec.rb spec/vcr_cassettes/shopping/check_availability_with_board_code.yml spec/vcr_cassettes/shopping/check_availability_multi_board.yml
git commit -m "feat: add optional board_code param to check_availability"
```

---

### Task 3: Flag-off 422 → ValidationError coverage

**Files:**
- Test: `spec/platform_client/requests_spec.rb` (append inside `describe '.check_rate'`, after `context 'with valid parameters'`)
- Create: `spec/vcr_cassettes/shopping/check_rate_multi_board_disabled.yml`

No production code changes — this task proves the existing error mapping (`VALIDATION_ERROR` → `Errors::ValidationError`) covers the Platform's flag-off rejection, per spec section 3.

**Interfaces:**
- Consumes: `Requests.check_rate(..., board_code:)` from Task 1; existing `Errors::ValidationError` with `#error_code`, `#error_reason`, `#message` accessors from `lib/platform_client/errors.rb`.
- Produces: nothing new.

- [ ] **Step 1: Create the VCR cassette**

Create `spec/vcr_cassettes/shopping/check_rate_multi_board_disabled.yml` with exactly (body mirrors the Platform's `ExceptionHandler#validation_error` structured format):

```yaml
---
http_interactions:
- request:
    method: get
    uri: https://kabuk-platform.com/api/check_rate?adults_count=1&board_code=half_board&check_in_date=2025-01-23&check_out_date=2025-01-25&country_code=JP&language=en-US&nationality=JP&property_code=bk60&room_code=104
    body:
      encoding: US-ASCII
      string: ''
    headers:
      Content-Type:
      - application/json
      Accept-Encoding:
      - gzip
      User-Agent:
      - API Client for Kabuk Platform -
      Authorization:
      - Bearer <BEARER_TOKEN>
      Accept:
      - "*/*"
  response:
    status:
      code: 422
      message: Unprocessable Entity
    headers:
      Content-Type:
      - application/json; charset=utf-8
      X-Request-Id:
      - 8ea0fb9f-8ab3-55ee-b7e9-3d9246f55812
    body:
      encoding: UTF-8
      string: '{"errors":[{"code":"VALIDATION_ERROR","message":"Board code multi-board support is not enabled","reason":"INVALID_RECORD","details":{"field":"board_code"}}]}'
  recorded_at: Wed, 23 Jul 2026 04:00:00 GMT
recorded_with: VCR 6.3.1
```

- [ ] **Step 2: Write the test**

In `spec/platform_client/requests_spec.rb`, inside `describe '.check_rate'`, after the closing `end` of `context 'with valid parameters'`, add:

```ruby
    context 'with a non-room_only board_code while multi-board support is disabled' do
      it 'raises ValidationError with the structured error details', vcr: { cassette_name: 'shopping/check_rate_multi_board_disabled' } do
        expect do
          described_class.check_rate(
            property_code: 'bk60',
            room_code: '104',
            check_in_date: '2025-01-23',
            check_out_date: '2025-01-25',
            adults_count: 1,
            country_code: 'JP',
            board_code: 'half_board'
          )
        end.to raise_error(PlatformClient::Errors::ValidationError) do |error|
          expect(error.error_code).to eq 'VALIDATION_ERROR'
          expect(error.error_reason).to eq 'INVALID_RECORD'
          expect(error.error_details).to eq({ 'field' => 'board_code' })
          expect(error.message).to eq 'Board code multi-board support is not enabled'
        end
      end
    end
```

- [ ] **Step 3: Run the test to verify it passes**

Run: `bundle exec rspec spec/platform_client/requests_spec.rb -e 'multi-board support is disabled'`
Expected: PASS immediately (error routing already exists — this is regression coverage, not TDD of new behavior). If it FAILS, do not patch the test to match — investigate `Requests::Base#build_error` / `Errors::ClientError` with the systematic-debugging skill; a failure here means the spec's "no error changes needed" claim is wrong and the plan must be revised.

- [ ] **Step 4: Commit**

```bash
git add spec/platform_client/requests_spec.rb spec/vcr_cassettes/shopping/check_rate_multi_board_disabled.yml
git commit -m "test: cover 422 ValidationError for board_code when multi-board is disabled"
```

---

### Task 4: Version bump, CHANGELOG, full verification

**Files:**
- Modify: `lib/platform_client/version.rb`
- Modify: `CHANGELOG.md` (currently an empty file)
- Modify: `Gemfile.lock` (regenerated by bundler from the new version)

**Interfaces:**
- Consumes: everything above.
- Produces: releasable gem version `0.3.0`.

- [ ] **Step 1: Bump version**

In `lib/platform_client/version.rb`, change:

```ruby
  VERSION = '0.3.0'
```

- [ ] **Step 2: Write CHANGELOG**

Replace the (empty) `CHANGELOG.md` contents with:

```markdown
# Changelog

## [0.3.0] - 2026-07-23

### Added

- Optional `board_code` parameter on `PlatformClient::Requests.check_rate` and
  `PlatformClient::Requests.check_availability` to target a boarding (meal) type
  (`room_only`, `breakfast`, `lunch`, `dinner`, `half_board`, `full_board`,
  `all_inclusive`). Omitted → previous behavior (Platform defaults apply:
  `room_only` for check_rate, all offered boards for check_availability).
  Requires multi-board support to be enabled on the Platform for
  non-`room_only` values.
```

- [ ] **Step 3: Refresh Gemfile.lock**

Run: `bundle install`
Expected: `Gemfile.lock` now shows `platform_client (0.3.0)`. If bundler is unavailable locally, use the Docker flow: `./build.sh`.

- [ ] **Step 4: Full verification**

Run: `bundle exec rspec`
Expected: 0 failures.

Run: `bundle exec rubocop`
Expected: no offenses.

- [ ] **Step 5: Commit**

```bash
git add lib/platform_client/version.rb CHANGELOG.md Gemfile.lock
git commit -m "chore: bump version to 0.3.0 and add changelog"
```
