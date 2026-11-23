---
name: flutter-faltool-dart-faltool-utils
description: Use when writing or changing helper code with dart_faltool, including String, DateTime, Duration, number, Object, collection, Future, and Stream extensions, TypeId, UuidGenerator, AppInfo, constant-time comparison, JSON converters, and TokenBucketPolicy, or before adding a utility dependency, since it already re-exports dartx, rxdart, fpdart, intl, and more.
---

# dart_faltool utils

Answers "does dart_faltool already provide this?" here and routes "how do I call it?" to one file under `references/`. `package: dart_faltool`; its barrel is also where the third-party libraries listed in `references/third-party.md` come from.

## Capability map

| Need                                           | Use                                                                                                                                                                                                                                                                                                                                                                                                        | Ref                         |
|------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------|
| String / String?                               | `toIntOrZero`, `isEmail`, `toCamelCase`, `maskEmail`, `toEnum<T>()`, `toBase64`                                                                                                                                                                                                                                                                                                                            | `references/extensions.md`  |
| DateTime / Duration                            | `isSameDay`, `addMonth`, `toRelative`, `weekOfYear`, `toHumanReadable`                                                                                                                                                                                                                                                                                                                                     | `references/extensions.md`  |
| num / int / double                             | `clampValue`, `inRange`, `roundToPlace`, `toPercentage`, `orZero`                                                                                                                                                                                                                                                                                                                                          | `references/extensions.md`  |
| Object / dynamic                               | `let`, `also`, `takeIf`, `asIntOrNull`, `asMapOr`                                                                                                                                                                                                                                                                                                                                                          | `references/extensions.md`  |
| Iterable / List / Map / Enum / Future / Stream | `removeDuplicatesBy`, `deepMerge`, `getPath`, `byValue`, `retryWithBackoff`, `combineLatest`                                                                                                                                                                                                                                                                                                               | `references/extensions.md`  |
| IDs, app version, security helpers             | `TypeId`, `UuidGenerator`, `AppInfo`, `nowUtc`, `constantTimeEquals`, `randomDelay`, `JsonSerializeUtil`, `DurationMillisecondsConverter`                                                                                                                                                                                                                                                                  | `references/utils.md`       |
| Third-party libs, free with this package       | `rxdart`, `fpdart`, `equatable`, `dartx`, `intl`, `timeago`, `numeral`, `big_decimal`, `clock`, `hashlib`, `resilience` (without `Retry`, `RetryEvent`, `Timeout`), `retry`, `logger`, `stack_trace`, `version`, `time`, `rrule`, `data`, `enum_to_string`, `meta`, `freezed_annotation`, `json_annotation`, `dart:async/convert/math/typed_data` | `references/third-party.md` |

## Do not reinvent

- Before adding a pub dependency or writing a helper, scan the map above and `references/third-party.md`.
- When this package's barrel is imported, do not also import `rxdart` or any other library it re-exports; the symbols are already in scope.
- Never `import 'dart:io'`; the package compiles to web. Use `package:universal_io/io.dart`, added to your own pubspec (it is not re-exported).

## Gotchas

- Hidden symbols: `dart_faltool` hides `dart:math` `log`, which collides with `dart:developer`'s (write `import 'dart:math' as math;` and `math.log`), and `dartx` `IterableAll`, `IterableAppend`, `IterableFilter` (use `where`), `IterableNumAverageExtension`, `IterableNumSumExtension`, `IterablePartition`, `IterableZip`, `MapOrEmpty`, `NumCoerceInRangeExtension`, `StringCapitalizeExtension` and `fpdart` `State`, `Task`.

## Out of scope

General usage of the re-exported libraries, and package internals.
