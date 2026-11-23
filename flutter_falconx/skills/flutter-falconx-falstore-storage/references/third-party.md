# Third-party

Every package here reaches your app once you depend on `flutter_falstore`. Do not add a duplicate direct dependency for what it already brings in, and do not pin a different version than the constraint in `flutter_falstore/pubspec.yaml` without checking it resolves against the git-pinned `flutter_falstore`.

| Package | For | Platform gaps |
|---|---|---|
| `flutter_secure_storage` | Platform-native secure storage backing `SecureStorage` | web keeps AES-GCM-encrypted values in `window.localStorage` (`sessionStorage` when the `useSessionStorage` option is set), not in the Keychain/Keystore path; see `references/storage.md` |
