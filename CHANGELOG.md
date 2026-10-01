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

### Changed

- `PlatformClient::Requests.check_availability` no longer defaults `adults_count`
  to `1`. When omitted, the parameter is not sent and the Platform returns
  availabilities for all available occupancies.
