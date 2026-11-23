# Extensions

`package: dart_faltool` unless marked. `dartx` is also re-exported (minus the hidden members in `third-party.md`), so `firstOrNullWhere`, `sortedBy`, `groupBy`, `Pair`, and friends exist too.

## String

- Convert: `toIntOrZero`, `toDoubleOrZero`, `toBoolean`, `toBooleanOrNull`, `toMap`, `toMapOrNull`, `toMapOrEmpty`, `toByte`, `hashSha256`, `removeHttp`, `containsIgnoreCase`, `countOccurrence`, `escapeHtml`, `unescapeHtml`.
- Format: `toCamelCase`, `toSnakeCase`, `toPascalCase`, `toKebabCase`, `capitalize`, `capitalizeWord`, `truncate`, `maskPhoneNumber`, `maskEmail`.
- Validate: `isUrl` / `isNotUrl`, `isEmail` / `isNotEmail`, `isNumeric`, `isJson` / `isNotJson`, `isPhoneNumber` / `isNotPhoneNumber`, `isTime` / `isNotTime`, `removeWhiteSpace`, `removeHtmlTags`, `normalizeWhitespace`; patterns in `FormatRegex`.
- Base64: `isBase64`, `toBase64`, `fromBase64ToString`, `fromBase64ToBytes`. `isBase64` is true for non-empty input that `fromBase64ToBytes` decodes: standard or URL-safe alphabet, padded or unpadded.
- Enum: `toEnum<T>(List<T> values, {defaultValue, caseSensitive = false})`, `toEnumOrNull<T>(values, {caseSensitive})`, `isValidEnum<T>()`.

`String?`: `or(default)`, `toIntOrNull`, `toIntOrZero`, `toDoubleOrNull`, `toDoubleOrZero`, `toBooleanOrNull`, `toMapOrNull`, `toMapOrEmpty`, `isUrl`, `isEmail`, `isJson`, `removeWhiteSpace`, `normalizeWhitespace`, `capitalize`, `truncate`, `maskPhoneNumber`, `maskEmail`.

## DateTime and Duration

`DateTime`: `quarter`, `weekOfYear`, `isPast`, `isFuture`, `isSameDay`, `isSameMonth`, `isSameYear`, `isBetween`, `addDay`, `subtractDay`, `addMonth`, `subtractMonth`, `addYear`, `subtractYear`, `nextWeekday`, `previousWeekday`, `format(pattern)`, `toIso8601`, `toDateOnly`, `toTimeOnly`, `toShortDate`, `toFullDate`, `toMonthYear`, `toRelative`, `humanReadableDay`, `toUnixTimestamp`, `toJsTimestamp`, `age`, `daysUntil`, `hoursUntil`, `isValidDateRange`.

`DateTime?`: `isNullOrPast`, `isNullOrFuture`, `format`, `toRelative`, `orNow`, `orDefault`, `toUnixTimestamp`, `age`.

`int` to time: `fromUnixToDateTime`, `fromUnixToLocalDateTime`, `fromJsToDateTime`, `fromJsToLocalDateTime`, `isValidDayOfMonth`. `Duration`: `toHumanReadable`, `toTimeString`, `inYears`. The `time` package adds `5.seconds`, `2.days`.

## Numbers

- `int`: `absolute`, `clampValue`, `atLeast`, `atMost`, `inRange`, `time(fn)`, `generate<T>(fn)`.
- `double`: `roundToPlace`, `absolute`, `clampValue`, `atLeast`, `atMost`, `inRange`, `isWhole`, `formatDecimal`, `toPercentage`, `toDegrees`, `toRadians`, `fractionalPart`.
- `num`: `absolute`, `clampValue`, `atLeast`, `atMost`, `inRange`, `isZero`, `lerp`, `mapRange`.
- `int?` / `double?` / `num?`: `toDoubleOrZero`, `toDoubleOrNull`, `toIntOrZero`, `orDefault`, `orZero`, `isNullOrZero`, `isNotNullOrZero`, `isPositive`, `isNegative`, `isEvenOrFalse`, `isOddOrFalse`, `roundToPlace`, `format`, `toPercentage`.

## Object and dynamic

- `T?`: `let`, `map`, `mapOr`, `mapOrElse`, `orDefault`, `orElse`, `takeIf`, `takeUnless`, `fold`, `match`, `chain`, `isNull`, `isNotNull`, `toFuture`, `toFutureOr`.
- `T`: `also`, `run`, `applyIf`, `applyIfLazy`, `wrapInList`, `asSet`, `asFuture`, `asStream`, `isIn`, `isNotIn`.
- `dynamic` casts: `asString` / `asStringOrNull` / `asStringOr(default)` and the same trio for `Int`, `Double`, `Num`, `Bool`, `BigInt`, `BigDecimal`, `DateTime`, `Duration`, `List`, `Map`. Non-null variants throw `FormatException`.

## Collections

- `Iterable<T>`: `reduceOrNull`, `reduceSafe`, `randomElement`; `Iterable<num>.average`; `Iterable<Object?>`: `sum`, `average`.
- `Iterable<T>?`: `isNullOrEmpty`, `isNotNullOrEmpty`, `orEmpty`, `orEmptyList`, `orEmptySet`, `ifNotEmpty`.
- `List<V>`: `removeNull`, `mapAsync`, `copy`, `deepCopy`, `edit`, `editAll`, `getOrDefault`, `removeFirst`, `removeAll`, `removeDuplicate`, `removeDuplicatesBy`, `move`, `rotate`, `indicesWhere`, `insertUnique`, `insertSorted`, `padRight`, `padLeft`, `countBy`, `mode`. `List<V>?`: `futureAsyncMap`, `orEmpty`, `getOrNull`, `ifNotEmpty`.
- `Map<K, V>`: `removeNullOrEmptyString`, `getOrDefault`, `where`, `merge`, `invert`, `groupByKey`, `sortByKey`, `sortByValue`, `pick`, `omit`, `setPath`, `getPath`; `Map<String, dynamic>.deepMerge`. `Map?`: `isNullOrEmpty`, `isNotNullOrEmpty`, `orEmpty`, `ifNotEmpty`.

## Enum

`Enum`: `toValueString`, `toFormattedString`, `enumIndex`, `isEqual`, `isIn`, `isNotIn`. `List<T extends Enum>`: `toValueString`, `byValue`, `byValueOrNull`, `toMap`, `toReverseMap`, `whereValue`. `T?`: `toValueStringOrNull`, `toValueStringOr`, `isEqual`, `isIn`, `isNotIn`, `orDefault`.

## Future

`Future<T>`: `timeoutWithDefault`, `timeoutWithCallback`, `retryWithBackoff`, `ignoreError`, `onErrorDo`, `mapSuccess`, `mapError`, `whenCompleteDo`, `guard`, `delayed`, `cancelAfter`, `timed`, `toStream`, `toEither`. `Future<T>?`: `orDefault`, `orNull`, `whenNotNull`. `Future<T?>`: `mapIfNotNull`, `defaultIfNull`, `where`. `Result` wrappers (`toResult`, `mapResult`, ...) are in `dart_falmodel`; the skill shipped for that package documents them.

## Stream

`Stream<T>`: `mapTransform`, `whereStream`, `asyncMapStream`, `combineLatest`, `takeWhileStream`, `skipWhileStream`, `ignoreError`, `count`. `Stream<T>?`: `isNull`, `isNotNull`, `orEmpty`, `ifNotNull`, `listenSafely`. `rxdart` operators are also in scope.

`Either` and `Pair` failure-or-data extensions are in `dart_falmodel`; the skill shipped for that package documents them.
