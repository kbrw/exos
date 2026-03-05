# CHANGELOG

## 2.1.1

### Fixed

- Replace usage of function `Keyword.validate/2` which is not usable with Elixir v1.9

## 2.1.0

### Changed

- Soft deprectated passing options with multiple arguments, prefer using named options
  now.
- Added configuration option for ETF encoding.
  You can now communicate with an outdated program by passing `etf_opts: [version: 1]`
  for example.
