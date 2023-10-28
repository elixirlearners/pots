# Changelog

## v0.1.2 (2023-10-28)
- Bufix
  - Fixed an issue when logging status of `mix pot.clean` was referencing
  a possible `nil` key in map
  - Removed having the `--file` option as default in `mix pot.clean`

## v0.1.1 (2023-10-28)
- Bufix
  - Added a runtime_cmd_output command because runtime_cmd only returned an iostruct

## v0.1.0 (2023-10-28)
- Enhancements
  - First version created
  - Support for docker, podman, and nerdctl
 