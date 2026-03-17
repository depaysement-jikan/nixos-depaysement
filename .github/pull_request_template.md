## Description

<!-- Provide a brief summary of the changes and the motivation behind them. -->

## Type of Change

- [ ] ✨ New Feature
- [ ] 🐛 Bug Fix
- [ ] ⚙️ Configuration Change
- [ ] ♻️ Refactor
- [ ] 📚 Documentation Update
- [ ] 🗑️ Removal/Deprecation

## Quality Assurance

- [ ] Configuration has been tested on the target host (e.g., `tsukinara`).
- [ ] Code follows the existing style and formatting.
- [ ] No secrets have been accidentally committed in plain text.

## Flake Health & Consistency

- [ ] `nix flake check` passes successfully across all outputs.
- [ ] `nix flake show` confirms the flake structure is valid.
- [ ] All NixOS configurations (e.g., `tsukinara`) evaluate without errors.
- [ ] `flake.lock` is consistent and was only updated if intentional.
- [ ] Files are formatted using the project's preferred formatter (e.g., `alejandra` or `nixfmt`).

## Project Specifics

- [ ] **Secrets:** Any new secrets have been added via `sops` and are properly referenced.
- [ ] **Modules:** If a new module was added, it is correctly imported in `default.nix`.
- [ ] **Hardware:** If hardware-specific, `hardware-configuration.nix` has been updated or verified.
- [ ] **Home Manager:** Changes to user environment have been verified with `home-manager switch`.

## Screenshots / Logs

<!-- If applicable, add screenshots or terminal output to demonstrate the changes. -->

## Additional Notes

<!-- Any other context or "gotchas" for the reviewer. -->
