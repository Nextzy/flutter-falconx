# Third-party re-exports

`dart_falmodel` re-exports no third-party library: its barrel exports only its own `exceptions`, `extensions`, `feedbacks`, `models`, and `networks`. `Either` (`fpdart`), `Pair` (`dartx`), `Equatable`, and the `freezed_annotation` and `json_annotation` annotations reach your code through `dart_faltool`; dio types such as `Response` and `RequestOptions` reach it through `dart_falconnect` or your own `dio` dependency.

## Not re-exported

`dart_falmodel` alone does not re-export `dio` or `dart_faltool`; depend on those directly when you skip the packages that re-export them. Add the dev tools `build_runner`, `freezed`, and `json_serializable` to your own pubspec when you generate code for models you write.
