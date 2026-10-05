# Changelog

## [0.4.0] - 2026-10-05

### Added

- `PlatformClient::Requests.update_room_occupancy(property_code:, room_code:, adults_counts:, changed_at:)`
  wraps `PUT /api/hafh/properties/:property_code/rooms/:room_code/occupancy` and returns
  `PlatformClient::Responses::RoomOccupancy`.
  - `adults_counts` is sent as given, so `[]` switches the room off.
  - A `Time` `changed_at` is serialized with microseconds (`iso8601(6)`); a String is sent as given.
  - Both path segments are URL-encoded.
- Error classes for the room occupancy PUT, routed by the error reason under `HAFH_ROOM_OCCUPANCY_ERROR`
  (no other endpoint's routing changes):
  - `Errors::RoomOccupancyStaleChangeError` (409 `STALE_CHANGE`) and `Errors::RoomOccupancyConflictError`
    (409 `CONFLICTING_CHANGE`), both exposing the stored row via `#current`.
  - `Errors::RoomOccupancyRejectedError < ValidationError` for the 422 reasons, read via `#error_reason`.

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
